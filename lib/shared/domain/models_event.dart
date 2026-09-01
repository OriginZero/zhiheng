import 'dart:convert';

import 'enums.dart';

/// 结构化医疗事件（开发文档 §7：Event First）。
///
/// 所有重要患者行为（用药、治疗、测量、症状、检验、照片、任务完成……）
/// 都沉淀为 Event，供时间线与趋势分析使用。
///
/// 历史不可变（§44）：事件一旦创建不改写；更正通过新增事件体现。
/// 高频强类型数据未来可加疾病专用表（混合模式），当前统一用 [payload]。
class HealthEvent {
  const HealthEvent({
    required this.id,
    required this.patientId,
    this.diseaseId,
    required this.type,
    required this.occurredAt,
    required this.createdAt,
    this.title,
    this.source = EventSource.user,
    this.payload = const {},
    this.notes,
  });

  final String id;
  final String patientId;
  final String? diseaseId;
  final EventType type;

  /// 事件实际发生时间（时间线排序依据）。
  final DateTime occurredAt;
  final DateTime createdAt;

  /// 事件标题，如「二甲双胍 500mg」。
  final String? title;

  /// 事件来源。
  final EventSource source;

  /// 结构化负载，JSON 可序列化。
  /// 例如测量事件：{"metric": "fasting_glucose", "value": 6.8, "unit": "mmol/L"}。
  final Map<String, Object?> payload;
  final String? notes;

  String get payloadJson => jsonEncode(payload);

  HealthEvent copyWith({
    String? id,
    String? patientId,
    String? diseaseId,
    bool clearDiseaseId = false,
    EventType? type,
    DateTime? occurredAt,
    DateTime? createdAt,
    String? title,
    bool clearTitle = false,
    EventSource? source,
    Map<String, Object?>? payload,
    String? notes,
    bool clearNotes = false,
  }) {
    return HealthEvent(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: clearDiseaseId ? null : (diseaseId ?? this.diseaseId),
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      title: clearTitle ? null : (title ?? this.title),
      source: source ?? this.source,
      payload: payload ?? this.payload,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }
}

/// 事件来源（§7 的 source 字段）。
enum EventSource {
  user,
  doctorPlan,
  clinicalRule,
  system;

  String get labelZh => switch (this) {
        EventSource.user => '手动记录',
        EventSource.doctorPlan => '医生方案',
        EventSource.clinicalRule => '临床规则',
        EventSource.system => '系统',
      };
}
