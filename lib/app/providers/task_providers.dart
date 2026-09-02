import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_repository.dart';
import '../../shared/domain/domain.dart';
import 'core_providers.dart';

/// 当日任务列表（首页 Today，§10）。
final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchTasksForDay(localPatientId, DateTime.now());
});

/// 某疾病的未完成任务（疾病详情页）。
final diseaseTasksProvider = StreamProvider.family<List<Task>, String>(
  (ref, diseaseId) {
    final repo = ref.watch(repositoryProvider);
    return repo.watchDiseaseTasks(localPatientId, diseaseId);
  },
);

/// 完成任务：更新状态、写入时间线事件，并按规则生成后续任务。
///
/// 闭环（§2）：Task → Event（时间线）；周期任务 → 下一次到期；
/// 光疗完成 → 24h 后反应记录任务（§11 依赖任务示例）。
class CompleteTaskNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> complete(Task task,
      {TaskStatus status = TaskStatus.completed, String? notes}) async {
    final repo = ref.read(repositoryProvider);
    await repo.completeTask(task.id, status);

    // 任务完成后取消未触发的提醒。
    await repo.cancelTaskReminder(task.id);

    // 任务完成沉淀为事件，进入时间线（§7、§10 闭环）。
    if (status == TaskStatus.completed) {
      final now = DateTime.now();
      if (notes != null && notes.trim().isNotEmpty) {
        await repo.updateTaskNotes(task.id, notes.trim());
      }
      await repo.addEvent(
        HealthEvent(
          id: newId(),
          patientId: task.patientId,
          diseaseId: task.diseaseId,
          type: EventType.taskCompleted,
          occurredAt: now,
          createdAt: now,
          title: task.title,
          source: EventSource.user,
          payload: {
            'task_id': task.id,
            'task_type': task.type.name,
            'task_source': task.source.name,
          },
          notes: notes == null || notes.trim().isEmpty ? null : notes.trim(),
          taskId: task.id,
        ),
      );

      // 周期任务：自动生成下一次到期（§11）。
      if (task.isRecurring) {
        await _spawnNextOccurrence(repo, task, now);
      }
      // 光疗完成：24 小时后提醒记录皮肤反应（§11 依赖任务示例）。
      if (task.templateId == 'vitiligo.phototherapy') {
        await _spawnReactionRecord(repo, task, now);
      }
    }
  }

  /// 生成周期链的下一次任务（保持同一 templateId / recurrence 锚点）。
  Future<void> _spawnNextOccurrence(
    LocalRepository repo,
    Task completed,
    DateTime now,
  ) async {
    // 计划控制：计划被暂停 / 完成 / 取消后，不再生成新任务。
    if (completed.carePlanId != null) {
      final plan = await repo.getCarePlan(completed.carePlanId!);
      if (plan == null || plan.status != CarePlanStatus.active) {
        return;
      }
    }
    DateTime nextDue;
    try {
      nextDue = nextOccurrence(completed.recurrence, completed.dueAt);
    } on StateError {
      // 链已结束（超过 endAt）→ 不再生成。
      return;
    }
    final next = completed.copyWith(
      id: newId(),
      status: TaskStatus.pending,
      dueAt: nextDue,
      clearCompletedAt: true,
      createdAt: now,
      updatedAt: now,
    );
    await repo.saveTask(next);
  }

  /// 光疗完成后的反应记录任务（24h 后，建议完成）。
  Future<void> _spawnReactionRecord(
    LocalRepository repo,
    Task completed,
    DateTime now,
  ) async {
    await repo.saveTask(
      Task(
        id: newId(),
        patientId: completed.patientId,
        diseaseId: completed.diseaseId,
        carePlanId: completed.carePlanId,
        title: '记录光疗后皮肤反应（红斑/瘙痒等）',
        description: '观察治疗部位是否出现红斑、瘙痒、灼热或水疱，'
            '并记录开始与持续时间（供复诊参考）。',
        type: TaskType.record,
        source: TaskSource.clinicalRule,
        priority: TaskPriority.suggested,
        dueAt: completed.dueAt.add(const Duration(hours: 24)),
        templateId: 'vitiligo.phototherapy.reaction',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}

final completeTaskProvider =
    NotifierProvider<CompleteTaskNotifier, void>(CompleteTaskNotifier.new);

/// 逾期未完成任务（首页「需要关注」区）。
final overdueTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchOverdueTasks(localPatientId);
});

/// 某疾病的医疗照片（时间倒序）。
final photosProvider = StreamProvider.family<List<CarePhoto>, String>(
  (ref, diseaseId) {
    final repo = ref.watch(repositoryProvider);
    return repo.watchPhotos(localPatientId, diseaseId: diseaseId);
  },
);

/// 某疾病的光疗记录（时间倒序）。
final phototherapyRecordsProvider =
    StreamProvider.family<List<PhototherapyRecord>, String>(
  (ref, diseaseId) {
    final repo = ref.watch(repositoryProvider);
    return repo.watchPhototherapyRecords(
      localPatientId,
      diseaseId: diseaseId,
    );
  },
);

/// 撤销任务完成：恢复待办，清理派生任务与完成事件。
///
/// 撤销范围（§44 历史可更正）：
/// - 任务本身恢复 pending；
/// - 删除本次完成生成的周期下一次 / 光疗反应记录任务（若未完成）；
/// - 删除本次完成沉淀的时间线事件。
class RevertTaskNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> revert(Task task) async {
    final repo = ref.read(repositoryProvider);

    // 1. 清理派生任务：同一计划下、同一模板链的未完成任务。
    final spawned = await repo.pendingSpawnedTasks(
      carePlanId: task.carePlanId,
      templateId: task.templateId,
    );
    for (final spawnedTask in spawned) {
      if (spawnedTask.id != task.id) {
        await repo.deleteTask(spawnedTask.id);
      }
    }
    // 光疗反应记录任务模板不同，单独清理。
    if (task.templateId == 'vitiligo.phototherapy') {
      final reactions = await repo.pendingSpawnedTasks(
        carePlanId: task.carePlanId,
        templateId: 'vitiligo.phototherapy.reaction',
      );
      for (final reaction in reactions) {
        await repo.deleteTask(reaction.id);
      }
    }

    // 2. 删除本次完成的时间线事件。
    await repo.deleteEventsByTaskId(task.id);

    // 3. 任务恢复待办，重建提醒（如设置了提醒）。
    await repo.revertTaskCompletion(task.id);
    final restored = await repo.watchTasksForDay(
      task.patientId,
      task.dueAt,
    ).first;
    for (final t in restored) {
      if (t.id == task.id) {
        await repo.syncTaskReminder(t);
      }
    }
  }
}

final revertTaskProvider =
    NotifierProvider<RevertTaskNotifier, void>(RevertTaskNotifier.new);

/// 未来 7 天待办（首页「即将到期」）。
final upcomingTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchUpcomingTasks(localPatientId);
});

/// 疾病列表。
final diseasesProvider = StreamProvider<List<Disease>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchDiseases(localPatientId);
});

/// 管理计划列表。
final carePlansProvider = StreamProvider<List<CarePlan>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchCarePlans(localPatientId);
});

/// 某疾病的管理计划（疾病详情页）。
final diseaseCarePlansProvider = Provider.family<List<CarePlan>, String>(
  (ref, diseaseId) {
    final plans = ref.watch(carePlansProvider).value ?? const [];
    return plans.where((p) => p.diseaseId == diseaseId).toList();
  },
);

/// 时间线事件流（§9）：支持疾病 / 类型过滤。
final timelineEventsProvider =
    StreamProvider.family<List<HealthEvent>, TimelineFilter>(
  (ref, filter) {
    final repo = ref.watch(repositoryProvider);
    return repo.watchEvents(
      localPatientId,
      diseaseId: filter.diseaseId,
      type: filter.type,
    );
  },
);

/// 时间线过滤条件。
class TimelineFilter {
  const TimelineFilter({this.diseaseId, this.type});

  final String? diseaseId;
  final EventType? type;

  TimelineFilter copyWith({String? diseaseId, EventType? type}) =>
      TimelineFilter(
        diseaseId: diseaseId ?? this.diseaseId,
        type: type ?? this.type,
      );

  @override
  bool operator ==(Object other) =>
      other is TimelineFilter &&
      other.diseaseId == diseaseId &&
      other.type == type;

  @override
  int get hashCode => Object.hash(diseaseId, type);
}
