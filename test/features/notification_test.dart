import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/features/notification/notification_service.dart';
import 'package:zhiheng/features/notification/reminder_dispatcher.dart';
import 'package:zhiheng/shared/domain/domain.dart';
import 'package:zhiheng/shared/forms/task_form_sheet.dart';

/// 任务提醒通知测试（§11：Task → Reminder → Notification）。
///
/// 场景 1：syncTaskReminder 为带提醒的任务创建 pending 提醒（fireAt=dueAt-N）；
/// 场景 2：dispatchDue 对到期提醒触发通知并标记 fired；
/// 场景 3：未到期提醒不触发；
/// 场景 4：cancelTaskReminder 后到期不再触发；
/// 场景 5：TaskDraft/saveTaskDraft 携带 remindBeforeMinutes 保存后任务与提醒正确。
void main() {
  late ProviderContainer container;
  late LocalRepository repo;
  late FakeNotificationService fake;
  late ReminderDispatcher dispatcher;

  setUp(() {
    repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    fake = FakeNotificationService();
    dispatcher = ReminderDispatcher(repo, fake);
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await repo.close();
  });

  /// drift 存储精度为秒，测试时间统一对齐到秒。
  DateTime nowAligned({Duration offset = Duration.zero}) {
    final now = DateTime.now();
    final aligned = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );
    return aligned.add(offset);
  }

  Future<Task> saveTask({
    String id = 't1',
    String title = '测试任务',
    DateTime? dueAt,
    int? remindBeforeMinutes,
  }) async {
    final task = Task(
      id: id,
      patientId: localPatientId,
      title: title,
      type: TaskType.record,
      source: TaskSource.userCreated,
      dueAt: dueAt ?? nowAligned(offset: const Duration(hours: 2)),
      remindBeforeMinutes: remindBeforeMinutes,
    );
    await repo.saveTask(task);
    return task;
  }

  test('syncTaskReminder 创建 pending 提醒（fireAt=dueAt-30min）', () async {
    final dueAt = nowAligned(offset: const Duration(hours: 2));
    final task = await saveTask(dueAt: dueAt, remindBeforeMinutes: 30);

    await repo.syncTaskReminder(task);

    final reminders = await repo.dueReminders(dueAt).first;
    expect(reminders, hasLength(1));
    final r = reminders.single;
    expect(r.taskId, task.id);
    expect(r.status, ReminderStatus.pending);
    expect(r.fireAt, dueAt.subtract(const Duration(minutes: 30)));
  });

  test('dispatchDue 对到期提醒触发通知并标记 fired', () async {
    final dueAt = nowAligned(offset: const Duration(hours: 1));
    final task =
        await saveTask(id: 't1', title: '光疗', dueAt: dueAt, remindBeforeMinutes: 30);
    await repo.syncTaskReminder(task);
    final fireAt = dueAt.subtract(const Duration(minutes: 30));

    await dispatcher.dispatchDue(now: fireAt);

    // FakeNotificationService 记录了通知内容。
    expect(fake.scheduled, hasLength(1));
    final n = fake.scheduled.single;
    expect(n.title, '光疗');
    expect(n.body, '现在该做：光疗');
    expect(n.when, fireAt);
    expect(n.id, greaterThan(0));

    // 已标记 fired：再次查询无到期提醒，不会重复派发。
    final reminders = await repo.dueReminders(fireAt).first;
    expect(reminders, isEmpty);
    await dispatcher.dispatchDue(now: fireAt);
    expect(fake.scheduled, hasLength(1));
  });

  test('dispatchDue：未到期提醒不触发', () async {
    final dueAt = nowAligned(offset: const Duration(hours: 1));
    final task = await saveTask(dueAt: dueAt, remindBeforeMinutes: 30);
    await repo.syncTaskReminder(task);
    final fireAt = dueAt.subtract(const Duration(minutes: 30));

    await dispatcher.dispatchDue(
      now: fireAt.subtract(const Duration(minutes: 1)),
    );

    expect(fake.scheduled, isEmpty);
    expect(fake.cancelled, isEmpty);

    // 提醒仍是 pending，到点后可正常触发。
    final reminders = await repo.dueReminders(fireAt).first;
    expect(reminders.single.status, ReminderStatus.pending);
  });

  test('cancelTaskReminder 后到期不再触发', () async {
    final dueAt = nowAligned(offset: const Duration(hours: 1));
    final task = await saveTask(dueAt: dueAt, remindBeforeMinutes: 30);
    await repo.syncTaskReminder(task);
    final fireAt = dueAt.subtract(const Duration(minutes: 30));

    await repo.cancelTaskReminder(task.id);
    await dispatcher.dispatchDue(now: fireAt.add(const Duration(hours: 1)));

    expect(fake.scheduled, isEmpty);

    final reminders =
        await repo.dueReminders(fireAt.add(const Duration(hours: 1))).first;
    expect(reminders, isEmpty);
  });

  testWidgets('saveTaskDraft：remindBeforeMinutes 写入任务并同步提醒', (tester) async {
    final dueAt = nowAligned(offset: const Duration(hours: 2));
    late WidgetRef ref;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, r, _) {
            ref = r;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // drift 异步在真实事件循环执行，避免 FakeAsync 挂起。
    await tester.runAsync(() async {
      final draft = TaskDraft(
        title: '记录血压',
        type: TaskType.record,
        priority: TaskPriority.required,
        dueAt: dueAt,
        remindBeforeMinutes: 30,
      );
      await saveTaskDraft(ref, draft);

      final dayTasks = await repo.watchTasksForDay(localPatientId, dueAt).first;
      expect(dayTasks, hasLength(1));
      expect(dayTasks.single.title, '记录血压');
      expect(dayTasks.single.source, TaskSource.userCreated);
      expect(dayTasks.single.remindBeforeMinutes, 30);

      // 保存后同步生成的提醒也正确。
      final reminders = await repo.dueReminders(dueAt).first;
      expect(reminders.single.taskId, dayTasks.single.id);
      expect(reminders.single.status, ReminderStatus.pending);
      expect(reminders.single.fireAt, dueAt.subtract(const Duration(minutes: 30)));
    });
  });
}
