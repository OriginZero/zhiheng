import 'dart:convert';

import 'enums.dart';

/// 任务执行补充记录（开发文档 §10）。
///
/// 任务勾选完成时，除了状态与备注，不同疾病可能还要记录各自非标的执行细节
/// （如光疗每个部位的照射时长、该部位照片）。这些内容统一以 [TaskSupplement]
/// 结构化保存为 JSON，[schema] 标识内容格式，存储层不感知结构 —— 疾病/模板
/// 差异通过新 schema 扩展，不改表结构。
///
/// 生命周期（§44 更正语义）：
/// - 撤销完成（revert）**保留**补充记录，避免误勾选丢失执行数据；
/// - 仅当用户主动删除补充记录时才移除（连同关联照片）。
class TaskSupplement {
  const TaskSupplement({required this.schema, required this.content});

  /// 内容格式标识，如 `vitiligo.phototherapy.exposure.v1`。
  final String schema;

  /// schema 定义的结构化内容（JSON 可序列化）。
  final Map<String, Object?> content;

  /// 编码为数据库存储的 JSON 文本。
  String toJson() =>
      jsonEncode(<String, Object?>{'schema': schema, 'content': content});

  /// 容错解析：结构不合法/损坏时返回 null（不阻断任务流）。
  static TaskSupplement? tryParse(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final map = (jsonDecode(json) as Map).cast<String, Object?>();
      final schema = map['schema'];
      final content = map['content'];
      if (schema is! String) return null;
      return TaskSupplement(
        schema: schema,
        content: content is Map ? content.cast<String, Object?>() : {},
      );
    } catch (_) {
      return null;
    }
  }
}

/// 308nm 光疗任务的内置补充记录 schema（v1）。
///
/// content 结构：
/// ```json
/// {
///   "parts": [
///     {
///       "partId": "uuid",          // 部位行 id（照片关联用）
///       "name": "左前臂",           // 部位名称
///       "durationSeconds": 90,     // 照射时长（秒），1 分半 = 90
///       "photoIds": ["uuid", ...]  // care_photos 中该部位照片
///     }
///   ]
/// }
/// ```
/// 时长以秒存储、界面按分/秒录入展示（家用 308nm 设备常用时间剂量）。
/// 补充记录只做执行细节沉淀，不构成剂量建议（§4：以医生方案为准）。
const String kPhototherapyExposureSchema = 'vitiligo.phototherapy.exposure.v1';

/// 光疗部位补充记录条目。
class PhototherapyExposurePart {
  const PhototherapyExposurePart({
    required this.partId,
    required this.name,
    this.durationSeconds,
    this.photoIds = const [],
  });

  final String partId;
  final String name;
  final int? durationSeconds;
  final List<String> photoIds;

  Map<String, Object?> toJson() => <String, Object?>{
        'partId': partId,
        'name': name,
        'durationSeconds': durationSeconds,
        'photoIds': photoIds,
      };

  static PhototherapyExposurePart? tryFrom(Object? json) {
    if (json is! Map) return null;
    try {
      final map = json.cast<String, Object?>();
      final partId = map['partId'];
      final name = map['name'];
      if (partId is! String || name is! String) return null;
      return PhototherapyExposurePart(
        partId: partId,
        name: name,
        durationSeconds: map['durationSeconds'] is int
            ? map['durationSeconds'] as int
            : null,
        photoIds: map['photoIds'] is List
            ? (map['photoIds'] as List).cast<String>()
            : const [],
      );
    } catch (_) {
      return null;
    }
  }
}

/// 从 [TaskSupplement] 中提取光疗部位列表（未知 schema 返回空）。
List<PhototherapyExposurePart> phototherapyExposureParts(
  TaskSupplement? supplement,
) {
  if (supplement == null || supplement.schema != kPhototherapyExposureSchema) {
    return const [];
  }
  final raw = supplement.content['parts'];
  if (raw is! List) return const [];
  final parts = <PhototherapyExposurePart>[];
  for (final item in raw) {
    final part = PhototherapyExposurePart.tryFrom(item);
    if (part != null) parts.add(part);
  }
  return parts;
}

/// 时长展示（如 90 → "1 分 30 秒"；null → null）。
String? formatDurationZh(int? seconds) {
  if (seconds == null || seconds < 0) return null;
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m == 0) return '$s 秒';
  if (s == 0) return '$m 分钟';
  return '$m 分 $s 秒';
}

/// 补充记录的中文摘要（供时间线事件展示；用户备注优先于摘要）。
///
/// 照片只以数量概述（如「2 张照片」），不展开细节；细节由用户点击
/// 事件后在任务详情弹层查看。
String? supplementSummaryZh(TaskSupplement? supplement) {
  final parts = phototherapyExposureParts(supplement);
  if (parts.isEmpty) return null;
  final lines = <String>[];
  for (final part in parts) {
    final duration = formatDurationZh(part.durationSeconds);
    final photoCount =
        part.photoIds.isEmpty ? '' : '（${part.photoIds.length} 张照片）';
    final details = '${duration ?? ''}$photoCount';
    // 注意插值范围：'$part.name' 会把 part 对象整个 toString（输出
    // 「Instance of PhototherapyExposurePart」），必须用 ${part.name}。
    lines.add(details.isEmpty ? part.name : '${part.name} $details');
  }
  return '治疗记录：${lines.join('；')}';
}

/// 清洗历史脏数据中的 Dart 对象 toString 痕迹。
///
/// v1.8.0 的时间线事件备注曾因 `'$part.name'` 插值 bug 写入
/// 「治疗记录：Instance of PhototherapyExposurePart …」这类文本；
/// 历史事件不可变（§44），在展示层过滤，不做数据库改写。
String? sanitizeDisplayNotes(String? notes) {
  if (notes == null) return null;
  if (!notes.contains('Instance of ')) return notes;
  // 逐个移除「Instance of 'Xxx'」片段（Dart 默认 toString 带引号）及其
  // 后续属性访问残留（如 `.name`）。
  var cleaned =
      notes.replaceAll(RegExp(r"Instance of '?[\w<>]+'?(\.\w+)*"), '');
  cleaned = cleaned
      .replaceAll(RegExp(r'：\s+'), '：')
      .replaceAll(RegExp(r'；{2,}'), '；')
      .replaceAll(RegExp(r'[：；]+\s*$'), '')
      .replaceAll(RegExp(r'^[；\s]+'), '')
      .trim();
  // 只剩裸标签（「治疗记录：」被清空后残留前缀）→ 视为无内容。
  if (cleaned == '治疗记录') cleaned = '';
  return cleaned.isEmpty ? null : cleaned;
}

/// 血糖测量记录的内置补充记录 schema（v1）。
///
/// 任务驱动血糖监测：完成「空腹血糖」「餐后2小时血糖」「睡前血糖」等任务时，
/// 通过 [TaskSupplement] 记录当次读数。schema 可扩展（如未来加 CGM 趋势），
/// 存储层不感知结构。
///
/// content 结构：
/// ```json
/// {
///   "context": "fasting",      // 测量时点（GlucoseContext.name）
///   "value": 6.8,              // 血糖值（mmol/L）
///   "method": "fingerstick",   // 测量方式（GlucoseMethod.name）
///   "symptoms": ["出汗", "手抖"], // 症状（可多选，低血糖时必填）
///   "exercise": false,         // 是否运动前后
///   "isHypo": false,           // 低血糖标记（value < 3.9 自动置 true）
///   "meal": "breakfast",       // 餐次（postMeal 时可选：breakfast/lunch/dinner）
///   "notes": ""                // 备注
/// }
/// ```
/// 低血糖判定阈值 3.9 mmol/L 来自《中国糖尿病防治指南（2024版）》：
/// 1 级低血糖 3.0 ≤ 血糖 < 3.9 mmol/L；2 级 < 3.0 mmol/L。
const String kGlucoseReadingSchema = 'diabetes.glucose.reading.v1';

/// 低血糖阈值（mmol/L）：value < 3.9 视为低血糖范围。
const double kHypoglycemiaThreshold = 3.9;

/// 严重低血糖阈值（mmol/L）：value < 3.0 视为 2 级低血糖。
const double kSevereHypoglycemiaThreshold = 3.0;

/// 血糖测量记录条目。
class GlucoseReading {
  const GlucoseReading({
    required this.context,
    required this.value,
    this.method = GlucoseMethod.fingerstick,
    this.symptoms = const [],
    this.exercise = false,
    this.meal,
    this.notes,
  });

  final GlucoseContext context;
  final double value;
  final GlucoseMethod method;
  final List<String> symptoms;
  final bool exercise;

  /// 餐次（postMeal 时必填）。
  final String? meal;
  final String? notes;

  /// 低血糖自动判定：value < 3.9 mmol/L。
  bool get isHypo => value < kHypoglycemiaThreshold;

  /// 严重低血糖：value < 3.0 mmol/L。
  bool get isSevereHypo => value < kSevereHypoglycemiaThreshold;

  Map<String, Object?> toJson() => <String, Object?>{
        'context': context.name,
        'value': value,
        'method': method.name,
        'symptoms': symptoms,
        'exercise': exercise,
        if (meal != null) 'meal': meal,
        'isHypo': isHypo,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  static GlucoseReading? tryFrom(Object? json) {
    if (json is! Map) return null;
    try {
      final map = json.cast<String, Object?>();
      final contextName = map['context'];
      final value = map['value'];
      if (contextName is! String || value is! num) return null;
      final context = GlucoseContext.values.byName(contextName);
      final methodName = map['method'] as String?;
      final method = methodName != null
          ? GlucoseMethod.values.byName(methodName)
          : GlucoseMethod.fingerstick;
      final symptoms = map['symptoms'] is List
          ? (map['symptoms'] as List).cast<String>()
          : const <String>[];
      final exercise = map['exercise'] is bool && map['exercise'] as bool;
      final meal = map['meal'] as String?;
      final notes = map['notes'] as String?;
      return GlucoseReading(
        context: context,
        value: value.toDouble(),
        method: method,
        symptoms: symptoms,
        exercise: exercise,
        meal: meal,
        notes: notes,
      );
    } catch (_) {
      return null;
    }
  }
}

/// 从 [TaskSupplement] 中提取血糖读数（未知 schema 返回 null）。
GlucoseReading? glucoseReadingFrom(TaskSupplement? supplement) {
  if (supplement == null || supplement.schema != kGlucoseReadingSchema) {
    return null;
  }
  return GlucoseReading.tryFrom(supplement.content);
}

/// 血糖读数的中文摘要（供时间线事件展示；用户备注优先于摘要）。
String? glucoseReadingSummaryZh(
  TaskSupplement? supplement, {
  String? fallbackNotes,
}) {
  final reading = glucoseReadingFrom(supplement);
  if (reading == null) return fallbackNotes;
  final buffer = StringBuffer('${reading.context.labelZh} ');
  buffer.write('${reading.value} mmol/L');
  if (reading.isHypo) buffer.write('（低血糖）');
  if (reading.exercise) buffer.write(' · 运动前后');
  return buffer.toString();
}
