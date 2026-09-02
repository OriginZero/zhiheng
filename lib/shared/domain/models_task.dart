import 'enums.dart';
import 'recurrence.dart';

/// 任务（开发文档 §10、§11）。
///
/// 任务来源（[source]）必须可追踪：来自医生方案、临床规则、
/// 管理计划、用药计划、监测计划或用户自建，不得笼统归为 AI。
///
/// 周期任务：[recurrence] 非空且 [recurrence.isRecurring] 为真时，
/// 完成任务后自动生成下一次到期任务（保持同一 [templateId]，链可追踪）。
class Task {
  const Task({
    required this.id,
    required this.patientId,
    this.diseaseId,
    this.carePlanId,
    required this.title,
    this.description,
    required this.type,
    required this.source,
    this.priority = TaskPriority.required,
    this.status = TaskStatus.pending,
    required this.dueAt,
    this.completedAt,
    this.recurrence = TaskRecurrence.none,
    this.templateId,
    this.notes,
    this.remindBeforeMinutes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientId;
  final String? diseaseId;
  final String? carePlanId;
  final String title;
  final String? description;
  final TaskType type;
  final TaskSource source;
  final TaskPriority priority;
  final TaskStatus status;

  /// 任务到期时间（首页「今日任务」按日期分组）。
  final DateTime dueAt;
  final DateTime? completedAt;

  /// 重复规则（光疗每周 2–3 次、用药每日等）。
  final TaskRecurrence recurrence;

  /// 周期任务链的模板 id（同一链的所有任务共享）。
  final String? templateId;

  /// 执行备注（完成时填写，可事后补充）。
  final String? notes;

  /// 提前提醒分钟数（null=不提醒）。
  final int? remindBeforeMinutes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isDone => status != TaskStatus.pending;

  bool get isRecurring => recurrence.isRecurring;

  Task copyWith({
    String? id,
    String? patientId,
    String? diseaseId,
    bool clearDiseaseId = false,
    String? carePlanId,
    bool clearCarePlanId = false,
    String? title,
    String? description,
    bool clearDescription = false,
    TaskType? type,
    TaskSource? source,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    TaskRecurrence? recurrence,
    String? templateId,
    bool clearTemplateId = false,
    String? notes,
    bool clearNotes = false,
    int? remindBeforeMinutes,
    bool clearRemindBeforeMinutes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      diseaseId: clearDiseaseId ? null : (diseaseId ?? this.diseaseId),
      carePlanId: clearCarePlanId ? null : (carePlanId ?? this.carePlanId),
      title: title ?? this.title,
      description:
          clearDescription ? null : (description ?? this.description),
      type: type ?? this.type,
      source: source ?? this.source,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueAt: dueAt ?? this.dueAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      recurrence: recurrence ?? this.recurrence,
      templateId: clearTemplateId ? null : (templateId ?? this.templateId),
      notes: clearNotes ? null : (notes ?? this.notes),
      remindBeforeMinutes: clearRemindBeforeMinutes
          ? null
          : (remindBeforeMinutes ?? this.remindBeforeMinutes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 提醒（开发文档 §11：Reminder 建立在 Task 之上）。
///
/// 链路：CarePlan → Task → Reminder → Notification。
/// 本地版第一版只负责记录提醒定义与触发状态，
/// 系统通知由后续接入本地通知插件时补上。
class Reminder {
  const Reminder({
    required this.id,
    required this.taskId,
    required this.fireAt,
    this.status = ReminderStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String taskId;
  final DateTime fireAt;
  final ReminderStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Reminder copyWith({
    String? id,
    String? taskId,
    DateTime? fireAt,
    ReminderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fireAt: fireAt ?? this.fireAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
