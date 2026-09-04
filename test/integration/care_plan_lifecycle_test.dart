import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/features/task/disease_templates.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 管理计划生命周期仓储测试：
/// - 模板防重判据（同患者同模板任意状态只允许一份计划）；
/// - 暂停/恢复/完成 的状态与提醒副作用（作用域 = 单计划）；
/// - 删除级联：未完成任务清理、历史（已完成任务/事件）保留；
/// - 患者档案可选项（体重/身高）持久化。
void main() {
  late ProviderContainer container;
  late LocalRepository repo;

  setUp(() {
    repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await repo.close();
  });

  final photoTemplate = DiseaseTemplates.all
      .firstWhere((t) => t.id == 'vitiligo.phototherapy');

  /// 模板 → 计划 → 首任务（带提醒）。
  Future<(CarePlan, Task)> activateWithReminder({
    required DateTime start,
    String diseaseId = 'd1',
  }) async {
    final plan = photoTemplate.buildCarePlan(
      patientId: localPatientId,
      diseaseId: diseaseId,
      startAt: start,
      endAtMonths: photoTemplate.defaultEndAtMonths,
    );
    await repo.saveCarePlan(plan);
    final task = photoTemplate
        .buildFirstTask(
          patientId: localPatientId,
          diseaseId: diseaseId,
          carePlanId: plan.id,
          dueAt: start,
        )
        .copyWith(remindBeforeMinutes: 30);
    await repo.saveTask(task);
    await repo.syncTaskReminder(task);
    return (plan, task);
  }

  Future<Reminder?> reminderOf(String taskId) =>
      repo.getReminderForTask(taskId);

  test('模板防重判据：同患者同模板查询命中（任意状态占用）', () async {
    await activateWithReminder(start: DateTime(2026, 9, 7, 9));
    final existing = await repo.getCarePlanByTemplate(
      localPatientId,
      photoTemplate.id,
    );
    expect(existing, isNotNull);
    expect(existing!.templateId, photoTemplate.id);

    // 暂停后仍占用（不允许再创建重复计划）。
    await repo.pauseCarePlan(existing.id);
    final again = await repo.getCarePlanByTemplate(
      localPatientId,
      photoTemplate.id,
    );
    expect(again, isNotNull);
  });

  test('暂停：状态 paused 且未完成任务提醒取消；恢复：active 且提醒重建', () async {
    final (plan, task) = await activateWithReminder(
      start: DateTime.now().add(const Duration(hours: 2)),
    );

    final reminderBefore = await reminderOf(task.id);
    expect(reminderBefore, isNotNull);
    expect(reminderBefore!.status, ReminderStatus.pending);

    await repo.pauseCarePlan(plan.id);
    expect((await repo.getCarePlan(plan.id))!.status, CarePlanStatus.paused);
    final pausedReminder = await reminderOf(task.id);
    expect(pausedReminder!.status, ReminderStatus.cancelled);

    await repo.resumeCarePlan(plan.id);
    expect((await repo.getCarePlan(plan.id))!.status, CarePlanStatus.active);
    final resumedReminder = await reminderOf(task.id);
    expect(resumedReminder!.status, ReminderStatus.pending);
  });

  test('完成计划：终态 completed 且未完成任务提醒取消', () async {
    final (plan, task) = await activateWithReminder(
      start: DateTime.now().add(const Duration(hours: 2)),
    );
    await repo.completeCarePlan(plan.id);
    expect((await repo.getCarePlan(plan.id))!.status, CarePlanStatus.completed);
    expect((await reminderOf(task.id))!.status, ReminderStatus.cancelled);
  });

  test('暂停作用域 = 单计划：另一计划状态不受影响（防级联回归）', () async {
    final glucoseTemplate = DiseaseTemplates.all
        .firstWhere((t) => t.id == 'diabetes.glucose.fasting');
    final a = await activateWithReminder(start: DateTime(2026, 9, 7, 8));
    final planB = glucoseTemplate.buildCarePlan(
      patientId: localPatientId,
      diseaseId: 'd2',
      startAt: DateTime(2026, 9, 7, 8, 30),
    );
    await repo.saveCarePlan(planB);

    await repo.pauseCarePlan(a.$1.id);
    final statusA = (await repo.getCarePlan(a.$1.id))!.status;
    final statusB = (await repo.getCarePlan(planB.id))!.status;
    expect(statusA, CarePlanStatus.paused);
    expect(statusB, CarePlanStatus.active);
    expect(a.$1.id, isNot(planB.id));
  });

  test('删除计划：级联清理未完成任务与提醒，历史（已完成任务/事件）保留', () async {
    final (plan, task) = await activateWithReminder(
      start: DateTime.now().subtract(const Duration(hours: 1)),
    );

    // 制造一条完成历史（任务完成 + 事件）。
    await repo.completeTask(task.id, TaskStatus.completed);
    await repo.addEvent(
      HealthEvent(
        id: newId(),
        patientId: localPatientId,
        diseaseId: 'd1',
        type: EventType.taskCompleted,
        occurredAt: task.dueAt,
        createdAt: task.dueAt,
        title: task.title,
        source: EventSource.user,
        taskId: task.id,
      ),
    );
    // 未完成派生态（待清理）。
    await repo.saveTask(
      photoTemplate
          .buildFirstTask(
            patientId: localPatientId,
            diseaseId: 'd1',
            carePlanId: plan.id,
            dueAt: DateTime.now().add(const Duration(days: 2)),
          )
          .copyWith(id: newId()),
    );

    final overview = await repo.carePlanDeletionOverview(plan.id);
    expect(overview.pendingCount, 1);
    expect(overview.hasHistory, isTrue, reason: '存在已完成任务');

    await repo.deleteCarePlan(plan.id);

    expect(await repo.getCarePlan(plan.id), isNull);
    final tasksAfter = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(tasksAfter, isEmpty, reason: '未完成任务已级联清理');
    // 已完成任务与事件保留（历史不可变 §44）。
    final kept = await repo.getTaskById(task.id);
    expect(kept, isNotNull);
    expect(kept!.status, TaskStatus.completed);
    final events = await repo.watchEvents(localPatientId).first;
    expect(events.any((e) => e.taskId == task.id), isTrue);
  });

  test('无历史计划删除：overview 无数据面', () async {
    final (plan, _) = await activateWithReminder(
      start: DateTime.now().add(const Duration(hours: 2)),
    );
    final overview = await repo.carePlanDeletionOverview(plan.id);
    expect(overview.pendingCount, 1);
    expect(overview.hasHistory, isFalse);
    await repo.deleteCarePlan(plan.id);
    expect(await repo.getCarePlan(plan.id), isNull);
  });

  test('档案可选项：体重/身高保存并读回，可清除', () async {
    await bootstrapLocalPatient(repo);
    final patient = await repo.watchPatient(localPatientId).first;
    expect(patient, isNotNull);
    expect(patient!.weightKg, isNull);
    expect(patient.heightCm, isNull);

    await repo.savePatient(
      patient.copyWith(
        weightKg: 63.5,
        heightCm: 170,
        clearWeightKg: false,
        clearHeightCm: false,
      ),
    );
    final updated = await repo.watchPatient(localPatientId).first;
    expect(updated!.weightKg, 63.5);
    expect(updated.heightCm, 170);

    await repo.savePatient(
      updated.copyWith(
        weightKg: null,
        clearWeightKg: true,
        heightCm: null,
        clearHeightCm: true,
      ),
    );
    final cleared = await repo.watchPatient(localPatientId).first;
    expect(cleared!.weightKg, isNull);
    expect(cleared.heightCm, isNull);
  });
}
