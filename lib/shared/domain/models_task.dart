import 'enums.dart';

/// 任务（开发文档 §10、§11）。
///
/// 任务来源（[source]）必须可追踪：来自医生方案、临床规则、
/// 管理计划、用药计划、监测计划或用户自建，不得笼统归为 AI。
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isDone => status != TaskStatus.pending;

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
