import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/app/providers/task_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/features/task/disease_templates.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 疾病差异化集成测试：计划（CarePlan）→ 任务链（Task）→ 事件（Event）。
///
/// 场景 1：模板实例化为计划，计划生成首任务；
/// 场景 2：每周一三五的光疗链，完成一次 → 自动生成下一次；
/// 场景 3：计划暂停后完成当前任务 → 不再生成下一次；
/// 场景 4：光疗完成后 24h 生成「记录皮肤反应」任务；
/// 场景 5：HbA1c 每 3 个月复查任务链；
/// 场景 6：任务完成事件保留来源（时间线可追溯）。
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

  /// 模板 → 计划 → 首任务。
  Future<(CarePlan, Task)> activate(
    DiseaseTaskTemplate template,
    DateTime start, {
    String diseaseId = 'd1',
  }) async {
    final plan = template.buildCarePlan(
      patientId: localPatientId,
      diseaseId: diseaseId,
      startAt: start,
      endAtMonths: template.defaultEndAtMonths > 0
          ? template.defaultEndAtMonths
          : null,
    );
    await repo.saveCarePlan(plan);
    final task = template.buildFirstTask(
      patientId: localPatientId,
      diseaseId: diseaseId,
      carePlanId: plan.id,
      dueAt: start,
    );
    await repo.saveTask(task);
    return (plan, task);
  }

  test('模板实例化为计划，首任务带 carePlanId（来源可追踪）', () async {
    final template = DiseaseTemplates.all.firstWhere(
      (t) => t.id == 'vitiligo.phototherapy',
    );
    final (plan, task) = await activate(template, DateTime(2026, 9, 7, 19, 0));

    expect(plan.status, CarePlanStatus.active);
    expect(plan.templateId, 'vitiligo.phototherapy');
    expect(plan.endAt, DateTime(2027, 3, 7)); // 6 个月疗程
    expect(task.carePlanId, plan.id);
    expect(task.templateId, template.id);
    expect(task.source, TaskSource.clinicalRule);

    final plans = await repo.watchCarePlans(localPatientId).first;
    expect(plans.single.id, plan.id);
  });

  test('光疗周期链：完成 → 自动生成下一次，直到疗程结束', () async {
    final template = DiseaseTemplates.all.firstWhere(
      (t) => t.id == 'vitiligo.phototherapy',
    );
    final (plan, first) = await activate(
      template,
      DateTime(2026, 9, 7, 19, 0),
    ); // 周一

    await container.read(completeTaskProvider.notifier).complete(first);
    var tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    final wednesday = tasks.firstWhere(
      (t) => t.dueAt == DateTime(2026, 9, 9, 19, 0),
    ); // 周三
    expect(wednesday.carePlanId, plan.id);

    await container.read(completeTaskProvider.notifier).complete(wednesday);
    tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(tasks.any((t) => t.dueAt == DateTime(2026, 9, 11, 19, 0)), isTrue);

    // 链的 templateId / carePlanId 一致（来源可追踪，§10）。
    final chainTasks = tasks.where((t) => t.title == '308nm 光疗');
    expect(
      chainTasks.every((t) => t.templateId == 'vitiligo.phototherapy'),
      isTrue,
    );
    expect(chainTasks.every((t) => t.carePlanId == plan.id), isTrue);
  });

  test('计划暂停后：完成当前任务不再生成下一次', () async {
    final template = DiseaseTemplates.all.firstWhere(
      (t) => t.id == 'vitiligo.phototherapy',
    );
    final (plan, first) = await activate(
      template,
      DateTime(2026, 9, 7, 19, 0),
    ); // 周一

    await repo.updateCarePlanStatus(plan.id, CarePlanStatus.paused);

    await container.read(completeTaskProvider.notifier).complete(first);

    final tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(
      tasks.where((t) => t.templateId == 'vitiligo.phototherapy'),
      isEmpty,
    );
  });

  test('光疗完成后 24h 生成反应记录任务（依赖任务，§11）', () async {
    final template = DiseaseTemplates.all.firstWhere(
      (t) => t.id == 'vitiligo.phototherapy',
    );
    final (plan, first) = await activate(template, DateTime(2026, 9, 7, 19, 0));

    await container.read(completeTaskProvider.notifier).complete(first);

    final tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    final reaction = tasks.firstWhere(
      (t) => t.templateId == 'vitiligo.phototherapy.reaction',
    );
    expect(reaction.title, contains('皮肤反应'));
    expect(reaction.dueAt, DateTime(2026, 9, 8, 19, 0)); // 24h 后
    expect(reaction.priority, TaskPriority.suggested);
    expect(reaction.source, TaskSource.clinicalRule);
    expect(reaction.carePlanId, plan.id);
  });

  test('HbA1c 每 3 个月复查链', () async {
    final template = DiseaseTemplates.all.firstWhere(
      (t) => t.id == 'diabetes.hba1c',
    );
    final (_, first) = await activate(template, DateTime(2026, 9, 1, 9, 0));

    await container.read(completeTaskProvider.notifier).complete(first);

    final tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    final next = tasks.firstWhere((t) => t.templateId == 'diabetes.hba1c');
    expect(next.dueAt, DateTime(2026, 12, 1, 9, 0));
  });

  test('任务完成事件保留来源与模板（时间线可追溯）', () async {
    final template = DiseaseTemplates.all.firstWhere(
      (t) => t.id == 'diabetes.hba1c',
    );
    final (_, first) = await activate(template, DateTime(2026, 9, 1, 9, 0));

    await container.read(completeTaskProvider.notifier).complete(first);

    final events = await repo.watchEvents(localPatientId).first;
    final event = events.firstWhere((e) => e.title == first.title);
    expect(event.payload['task_source'], 'clinicalRule');
  });
}
