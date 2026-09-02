import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/app/providers/core_providers.dart';
import 'package:zhiheng/app/providers/task_providers.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/features/task/disease_templates.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 任务备注与撤销测试。
///
/// 场景 1：完成任务可带备注，备注进入任务与时间线事件；
/// 场景 2：事后补写备注；
/// 场景 3：撤销完成 → 任务恢复待办、时间线事件删除；
/// 场景 4：撤销光疗 → 自动生成的下一次与 24h 反应任务一并清理；
/// 场景 5：撤销后重新完成 → 链重新开始。
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

  Future<Task> saveTask({
    String id = 't1',
    String? diseaseId = 'd1',
    String? carePlanId,
    String? templateId,
    String title = '测试任务',
    TaskType type = TaskType.record,
    DateTime? dueAt,
    TaskRecurrence recurrence = TaskRecurrence.none,
  }) async {
    final task = Task(
      id: id,
      patientId: localPatientId,
      diseaseId: diseaseId,
      carePlanId: carePlanId,
      title: title,
      type: type,
      source: TaskSource.userCreated,
      dueAt: dueAt ?? DateTime(2026, 9, 1, 9),
      recurrence: recurrence,
      templateId: templateId,
    );
    await repo.saveTask(task);
    return task;
  }

  test('完成时带备注：任务与时间线事件都记录备注', () async {
    final task = await saveTask();
    await container
        .read(completeTaskProvider.notifier)
        .complete(task, notes: '剂量减半，无不适');

    final events = await repo.watchEvents(localPatientId).first;
    expect(events.single.notes, '剂量减半，无不适');
    expect(events.single.taskId, task.id);

    // 任务本身记录备注。
    final dayTasks =
        await repo.watchTasksForDay(localPatientId, DateTime(2026, 9, 1)).first;
    expect(dayTasks.single.notes, '剂量减半，无不适');
  });

  test('事后补写备注', () async {
    final task = await saveTask();
    await container.read(completeTaskProvider.notifier).complete(task);

    await repo.updateTaskNotes(task.id, '补记：有点瘙痒');

    final dayTasks =
        await repo.watchTasksForDay(localPatientId, DateTime(2026, 9, 1)).first;
    expect(dayTasks.single.notes, '补记：有点瘙痒');
  });

  test('撤销完成：任务恢复待办并保留备注，时间线事件删除', () async {
    final task = await saveTask();
    await container
        .read(completeTaskProvider.notifier)
        .complete(task, notes: '备注内容');

    await container.read(revertTaskProvider.notifier).revert(task);

    // 任务恢复待办。
    final dayTasks =
        await repo.watchTasksForDay(localPatientId, DateTime(2026, 9, 1)).first;
    expect(dayTasks.single.status, TaskStatus.pending);
    expect(dayTasks.single.completedAt, isNull);
    // 撤销保留执行备注与补充（§44 更正语义：只有用户主动删除才丢弃）。
    expect(dayTasks.single.notes, '备注内容');

    // 时间线事件删除。
    final events = await repo.watchEvents(localPatientId).first;
    expect(events.where((e) => e.taskId == task.id), isEmpty);
  });

  test('撤销光疗：下一次任务与 24h 反应任务一并清理', () async {
    final template = DiseaseTemplates.all
        .firstWhere((t) => t.id == 'vitiligo.phototherapy');
    final plan = template.buildCarePlan(
      patientId: localPatientId,
      diseaseId: 'd1',
      startAt: DateTime(2026, 9, 7, 19), // 周一
    );
    await repo.saveCarePlan(plan);
    final first = template.buildFirstTask(
      patientId: localPatientId,
      diseaseId: 'd1',
      carePlanId: plan.id,
      dueAt: DateTime(2026, 9, 7, 19),
    );
    await repo.saveTask(first);

    // 完成 → 生成周三任务 + 24h 反应任务。
    await container
        .read(completeTaskProvider.notifier)
        .complete(first, completedAt: first.dueAt);
    var tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(tasks.length, 2);

    // 撤销 → 全部清理，任务恢复待办。
    await container.read(revertTaskProvider.notifier).revert(first);
    tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(tasks.single.id, first.id);
    expect(tasks.single.status, TaskStatus.pending);
  });

  test('撤销后重新完成：周期链正常重新生成', () async {
    final template = DiseaseTemplates.all
        .firstWhere((t) => t.id == 'vitiligo.phototherapy');
    final plan = template.buildCarePlan(
      patientId: localPatientId,
      diseaseId: 'd1',
      startAt: DateTime(2026, 9, 7, 19),
    );
    await repo.saveCarePlan(plan);
    final first = template.buildFirstTask(
      patientId: localPatientId,
      diseaseId: 'd1',
      carePlanId: plan.id,
      dueAt: DateTime(2026, 9, 7, 19),
    );
    await repo.saveTask(first);

    await container
        .read(completeTaskProvider.notifier)
        .complete(first, completedAt: first.dueAt);
    await container.read(revertTaskProvider.notifier).revert(first);
    await container
        .read(completeTaskProvider.notifier)
        .complete(first, completedAt: first.dueAt);

    final tasks = await repo.watchDiseaseTasks(localPatientId, 'd1').first;
    expect(tasks.any((t) => t.dueAt == DateTime(2026, 9, 9, 19)), isTrue);
  });

  test('完成带治疗补充：补充落库，事件标记 has_supplement', () async {
    final task = await saveTask(title: '308nm 光疗');
    final supplement = TaskSupplement(
      schema: kPhototherapyExposureSchema,
      content: {
        'parts': [
          {
            'partId': 'p1',
            'name': '左前臂',
            'durationSeconds': 90, // 1 分半
            'photoIds': <String>[],
          },
        ],
      },
    );
    await container
        .read(completeTaskProvider.notifier)
        .complete(task, supplement: supplement, completedAt: task.dueAt);

    final dayTasks =
        await repo.watchTasksForDay(localPatientId, DateTime(2026, 9, 1)).first;
    final stored = dayTasks.single.supplement;
    expect(stored, isNotNull);
    expect(stored!.schema, kPhototherapyExposureSchema);
    expect(
      phototherapyExposureParts(stored).single.name,
      '左前臂',
    );
    expect(
      phototherapyExposureParts(stored).single.durationSeconds,
      90,
    );

    final events = await repo.watchEvents(localPatientId).first;
    expect(events.single.payload['has_supplement'], isTrue);
  });

  test('撤销保留补充记录；主动删除才丢弃（照片行一并清理）', () async {
    final task = await saveTask(title: '308nm 光疗');
    final supplement = TaskSupplement(
      schema: kPhototherapyExposureSchema,
      content: {
        'parts': [
          {
            'partId': 'p1',
            'name': '颈部',
            'durationSeconds': 60,
            'photoIds': ['ph1'],
          },
        ],
      },
    );
    await repo.addCarePhoto(
      CarePhoto(
        id: 'ph1',
        patientId: localPatientId,
        diseaseId: 'd1',
        taskId: task.id,
        kind: PhotoKind.lesion,
        filePath: 'C:/nonexistent/photo.jpg',
        takenAt: DateTime(2026, 9, 1, 9, 5),
      ),
    );
    await container
        .read(completeTaskProvider.notifier)
        .complete(task, notes: '有点红', supplement: supplement,
            completedAt: task.dueAt);

    // 撤销完成：状态恢复，但补充/备注/照片都保留。
    await container.read(revertTaskProvider.notifier).revert(task);
    var dayTasks =
        await repo.watchTasksForDay(localPatientId, DateTime(2026, 9, 1)).first;
    expect(dayTasks.single.status, TaskStatus.pending);
    expect(dayTasks.single.notes, '有点红');
    expect(dayTasks.single.supplement, isNotNull);
    expect(await repo.photosForTask(task.id), hasLength(1));

    // 用户主动删除补充：内容与关联照片行一并清理。
    await repo.deleteTaskSupplement(task.id);
    dayTasks =
        await repo.watchTasksForDay(localPatientId, DateTime(2026, 9, 1)).first;
    expect(dayTasks.single.supplement, isNull);
    expect(await repo.photosForTask(task.id), isEmpty);
  });
}
