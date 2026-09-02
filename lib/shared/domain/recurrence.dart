import 'dart:convert';

/// 任务重复规则（§11：周期任务）。
///
/// - 光疗：[RecurrenceFrequency.weekly] + weekdays（如周一/三/五，每周 2–3 次）；
/// - 用药：[RecurrenceFrequency.daily]（interval=1）；
/// - HbA1c 复查：[RecurrenceFrequency.monthly]（每 3 / 6 / 12 个月）。
///
/// 每周间隔（每 2 周等）以 [anchor]（链中第一次到期日所在周）为基准计数，
/// 保证整条任务链确定可复现。
class TaskRecurrence {
  const TaskRecurrence({
    required this.frequency,
    this.interval = 1,
    this.weekdays = const [],
    this.endAt,
    this.anchor,
  });

  /// 从不重复。
  static const TaskRecurrence none =
      TaskRecurrence(frequency: RecurrenceFrequency.none);

  final RecurrenceFrequency frequency;

  /// 每 N 天 / 每 N 周 / 每 N 月（最小 1）。
  final int interval;

  /// 每周重复的星期几（DateTime.weekday：1=周一 … 7=周日）。
  final List<int> weekdays;

  /// 重复结束日期（疗程结束）。
  final DateTime? endAt;

  /// 周期链锚点：第一次到期日（每 N 周计数基准）。
  final DateTime? anchor;

  bool get isRecurring => frequency != RecurrenceFrequency.none;

  String get descriptionZh {
    switch (frequency) {
      case RecurrenceFrequency.none:
        return '不重复';
      case RecurrenceFrequency.daily:
        return interval == 1 ? '每天' : '每 $interval 天';
      case RecurrenceFrequency.weekly:
        final days = weekdays.map(_weekdayZh).toList();
        final weekPart = interval == 1 ? '每周' : '每 $interval 周';
        return '$weekPart ${days.join('、')}';
      case RecurrenceFrequency.monthly:
        return '每 $interval 个月';
    }
  }

  static String _weekdayZh(int weekday) => const [
        '周一',
        '周二',
        '周三',
        '周四',
        '周五',
        '周六',
        '周日',
      ][(weekday - 1) % 7];

  String get weekdaysJson => jsonEncode(weekdays);

  static List<int> weekdaysFromJson(String? json) {
    if (json == null || json.isEmpty) return const [];
    return (jsonDecode(json) as List).cast<int>();
  }
}

/// 重复频率。
enum RecurrenceFrequency { none, daily, weekly, monthly }

/// 周期任务在 [from] 之后的下一次到期时间（保留时分）。
///
/// - 每日：[from] 后第 [interval] 天；
/// - 每周：允许星期几集合中，且与锚点周间隔为 [interval] 整数倍的最近日期；
/// - 每月：[from] 后第 [interval] 个月的相同日期。
///
/// 纯函数，不依赖时钟（可测试，§43 规则测试要求）。
DateTime nextOccurrence(TaskRecurrence recurrence, DateTime from) {
  final hour = from.hour;
  final minute = from.minute;

  DateTime at(DateTime d) => DateTime(d.year, d.month, d.day, hour, minute);

  DateTime? candidate;

  switch (recurrence.frequency) {
    case RecurrenceFrequency.none:
      throw StateError('non-recurring task has no next occurrence');
    case RecurrenceFrequency.daily:
      candidate = at(from.add(Duration(days: recurrence.interval)));
    case RecurrenceFrequency.weekly:
      if (recurrence.weekdays.isEmpty) {
        throw StateError('weekly recurrence requires weekdays');
      }
      final anchor = recurrence.anchor ?? from;
      final anchorWeekStart =
          anchor.subtract(Duration(days: anchor.weekday - 1));
      final allowed = recurrence.weekdays.toSet();

      var cursor = from.add(const Duration(days: 1));
      for (var i = 0; i < 400; i++) {
        final weeksSinceAnchor = cursor.difference(anchorWeekStart).inDays ~/ 7;
        if (allowed.contains(cursor.weekday) &&
            weeksSinceAnchor % recurrence.interval == 0) {
          candidate = at(cursor);
          break;
        }
        cursor = cursor.add(const Duration(days: 1));
      }
      if (candidate == null) {
        throw StateError('no next occurrence within search window');
      }
    case RecurrenceFrequency.monthly:
      candidate = at(DateTime(
        from.year,
        from.month + recurrence.interval,
        from.day,
      ));
  }

  final end = recurrence.endAt;
  if (end != null &&
      DateTime(candidate.year, candidate.month, candidate.day)
          .isAfter(DateTime(end.year, end.month, end.day))) {
    throw StateError('recurrence ended');
  }
  return candidate;
}

/// 在允许星期几集合内、[from]（含）之后最近的日期。用于生成链的首次任务。
///
/// 例：锚点规则选「周一/三/五」，今天周四 → 首次任务为本周五。
DateTime firstOccurrence(
  TaskRecurrence recurrence,
  DateTime fromDate, {
  DateTime? preferredStart,
}) {
  final start = preferredStart ?? fromDate;
  if (recurrence.frequency == RecurrenceFrequency.daily ||
      recurrence.frequency == RecurrenceFrequency.monthly) {
    return start;
  }
  if (recurrence.frequency == RecurrenceFrequency.weekly) {
    if (recurrence.weekdays.isEmpty) {
      throw StateError('weekly recurrence requires weekdays');
    }
    final allowed = recurrence.weekdays.toSet();
    var cursor = DateTime(start.year, start.month, start.day);
    for (var i = 0; i < 8; i++) {
      if (allowed.contains(cursor.weekday)) return cursor;
      cursor = cursor.add(const Duration(days: 1));
    }
  }
  return start;
}

/// 光疗链的「按实际完成日重排」函数。
///
/// 依据（见 docs/医学知识库.md，2024 版《白癜风诊疗共识》：
/// 308nm 光疗每周治疗 2～3 次）：模板按每周一三五排程，即两次治疗
/// 至少隔 2 个自然日。若任务在计划日期之外完成（提前/补做），后续任务
/// 不能继续从名义日期推算——那会把两次实际治疗压得过近（如周一任务
/// 周三补做，却仍生成周三的下一次）。因此从**实际完成日**起算：
/// 下次治疗不早于实际完成日后 2 个自然日（保持每周不超过 3 次的模板节奏），
/// 在允许星期集合中取最近日期；时刻沿用任务链的名义时刻
/// （[nominalDueAt] 的时分，模板链约定的治疗时刻）。
///
/// 与 [nextOccurrence] 一样做跨周/间隔（每 N 周）与疗程终点校验。
/// 纯函数，不依赖时钟（可测试）。仅用于每周型光疗模板链。
DateTime nextPhototherapyOccurrence(
  TaskRecurrence recurrence,
  DateTime completedAt,
  DateTime nominalDueAt,
) {
  if (recurrence.frequency != RecurrenceFrequency.weekly ||
      recurrence.weekdays.isEmpty) {
    throw StateError('phototherapy reschedule requires weekly recurrence');
  }
  final anchor = recurrence.anchor ?? nominalDueAt;
  final anchorWeekStart = anchor.subtract(Duration(days: anchor.weekday - 1));
  final allowed = recurrence.weekdays.toSet();
  final hour = nominalDueAt.hour;
  final minute = nominalDueAt.minute;

  // 实际完成日后第 2 个自然日起寻找（保证每次间隔 >= 2 天）。
  var cursor = DateTime(
    completedAt.year,
    completedAt.month,
    completedAt.day,
  ).add(const Duration(days: 2));

  DateTime? candidate;
  for (var i = 0; i < 8; i++) {
    final weeksSinceAnchor = cursor.difference(anchorWeekStart).inDays ~/ 7;
    if (allowed.contains(cursor.weekday) &&
        weeksSinceAnchor % recurrence.interval == 0) {
      candidate =
          DateTime(cursor.year, cursor.month, cursor.day, hour, minute);
      break;
    }
    cursor = cursor.add(const Duration(days: 1));
  }
  if (candidate == null) {
    throw StateError('no next phototherapy occurrence within search window');
  }

  final end = recurrence.endAt;
  if (end != null &&
      DateTime(candidate.year, candidate.month, candidate.day)
          .isAfter(DateTime(end.year, end.month, end.day))) {
    throw StateError('recurrence ended');
  }
  return candidate;
}
