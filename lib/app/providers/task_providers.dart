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

/// 完成任务：更新状态并写入时间线事件（闭环：Task → Event）。
class CompleteTaskNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> complete(Task task,
      {TaskStatus status = TaskStatus.completed}) async {
    final repo = ref.read(repositoryProvider);
    await repo.completeTask(task.id, status);

    // 任务完成沉淀为事件，进入时间线（§7、§10 闭环）。
    if (status == TaskStatus.completed) {
      final now = DateTime.now();
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
        ),
      );
    }
  }
}

final completeTaskProvider =
    NotifierProvider<CompleteTaskNotifier, void>(CompleteTaskNotifier.new);

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
