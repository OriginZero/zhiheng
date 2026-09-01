import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/app/providers/task_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/features/task/disease_templates.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 疾病差异化集成测试：周期任务链 + 光疗反应记录（§11）。
///
/// 场景 1：每周一三五的光疗链，完成一次 → 自动生成下一次；
/// 场景 2：光疗完成后 24h 生成「记录皮肤反应」任务；
/// 场景 3：HbA1c 每 3 个月复查任务链。
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

  test('光疗周期链：完成 → 自动生成下一次，直到疗程结束', () async {
    final template = DiseaseTemplates.all
        .firstWhere((t) => t.id == 'vitiligo.phototherapy');

    // 2026-09-07 是周一，作为锚点（首次光疗）。
    final first = template.buildFirstTask(
      patientId: localPatientId,
      diseaseId: 'd1',
      dueAt: DateTime(2026, 9, 7, 19, 0),
    );
    await repo.saveTask(first);

    // 完成第一次 → 应生成周三（9/9）的任务。
    await container.read(completeTaskProvider.notifier).complete(first);
    var tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(tasks.map((t) => t.title), contains('308nm 光疗'));
    final wednesday =
        tasks.firstWhere((t) => t.dueAt == DateTime(2026, 9, 9, 19, 0));
    expect(wednesday, isNotNull);

    // 完成周三 → 生成周五（9/11）。
    await container.read(completeTaskProvider.notifier).complete(wednesday);
    tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(tasks.any((t) => t.dueAt == DateTime(2026, 9, 11, 19, 0)), isTrue);

    // 链的 templateId 一致（来源可追踪，§10）。
    final chainTasks = tasks.where((t) => t.title == '308nm 光疗');
    expect(chainTasks.every((t) => t.templateId == 'vitiligo.phototherapy'),
        isTrue);
    expect(chainTasks.every((t) => t.source == TaskSource.clinicalRule),
        isTrue);
  });

  test('光疗完成后 24h 生成反应记录任务（依赖任务，§11）', () async {
    final template = DiseaseTemplates.all
        .firstWhere((t) => t.id == 'vitiligo.phototherapy');
    final first = template.buildFirstTask(
      patientId: localPatientId,
      diseaseId: 'd1',
      dueAt: DateTime(2026, 9, 7, 19, 0),
    );
    await repo.saveTask(first);

    await container.read(completeTaskProvider.notifier).complete(first);

    final tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    final reaction = tasks.firstWhere(
      (t) => t.templateId == 'vitiligo.phototherapy.reaction',
    );
    expect(reaction.title, contains('皮肤反应'));
    expect(reaction.dueAt, DateTime(2026, 9, 8, 19, 0)); // 24h 后
    expect(reaction.priority, TaskPriority.suggested);
    expect(reaction.source, TaskSource.clinicalRule);
  });

  test('HbA1c 每 3 个月复查链', () async {
    final template = DiseaseTemplates.all
        .firstWhere((t) => t.id == 'diabetes.hba1c');
    final first = template.buildFirstTask(
      patientId: localPatientId,
      diseaseId: 'd2',
      dueAt: DateTime(2026, 9, 1, 9, 0),
    );
    await repo.saveTask(first);

    await container.read(completeTaskProvider.notifier).complete(first);

    final tasks = await repo.watchDiseaseTasks(localPatientId, 'd2').first;
    final next = tasks.firstWhere((t) => t.templateId == 'diabetes.hba1c');
    expect(next.dueAt, DateTime(2026, 12, 1, 9, 0));
  });

  test('任务完成事件保留来源与模板（时间线可追溯）', () async {
    final template = DiseaseTemplates.all
        .firstWhere((t) => t.id == 'diabetes.hba1c');
    final first = template.buildFirstTask(
      patientId: localPatientId,
      diseaseId: 'd2',
      dueAt: DateTime(2026, 9, 1, 9, 0),
    );
    await repo.saveTask(first);

    await container.read(completeTaskProvider.notifier).complete(first);

    final events = await repo.watchEvents(localPatientId).first;
    final event = events.firstWhere((e) => e.title == first.title);
    expect(event.payload['task_source'], 'clinicalRule');
  });
}
