import '../../app/providers/core_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../shared/domain/domain.dart';
import 'notification_service.dart';

/// 提醒派发器（§11：Reminder → Notification）。
///
/// 把到期（pending 且 fireAt<=now）的提醒交给 [NotificationService]
/// 展示系统通知，随后标记为 fired，避免重复派发。
///
/// 通知 id 由任务 id 稳定派生（同一任务跨进程重启保持一致，
/// 保证重复派发时能覆盖旧的待展示通知）。
class ReminderDispatcher {
  ReminderDispatcher(this.repo, this.service);

  final LocalRepository repo;
  final NotificationService service;

  /// 派发所有到期提醒。[now] 供测试注入，默认取当前时间。
  Future<void> dispatchDue({DateTime? now}) async {
    final due = await repo.dueReminders(now ?? DateTime.now()).first;
    for (final reminder in due) {
      final task = await _findTask(reminder.taskId, reminder.fireAt);
      if (task == null) {
        // 任务已删除：不再展示通知，但标记已触发避免反复派发。
        await repo.markReminderFired(reminder.taskId);
        continue;
      }
      await service.schedule(
        id: _notificationId(reminder.taskId),
        title: task.title,
        body: '现在该做：${task.title}',
        when: reminder.fireAt,
      );
      await repo.markReminderFired(reminder.taskId);
    }
  }

  /// 按任务 id 回查任务标题。fireAt 可能落在任务到期的前一天（深夜跨零点），
  /// 因此同时查 fireAt 当天与次日两天的到期任务。
  Future<Task?> _findTask(String taskId, DateTime fireAt) async {
    for (final day in [
      fireAt,
      fireAt.add(const Duration(days: 1)),
    ]) {
      final tasks = await repo.watchTasksForDay(localPatientId, day).first;
      for (final task in tasks) {
        if (task.id == taskId) return task;
      }
    }
    return null;
  }

  /// 从任务 id 派生稳定的正整数通知 id。
  int _notificationId(String taskId) {
    final hash = taskId.hashCode & 0x7fffffff;
    return hash == 0 ? 1 : hash;
  }
}
