import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 核心闭环集成测试（开发文档 §2）：
///
/// 疾病 → 管理计划 → 任务 → 执行（完成）→ 事件 → 时间线
///
/// 每一环的数据都能被下一环查到，且来源可追踪（§10）。
void main() {
  late LocalRepository repo;

  setUp(() {
    repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
  });

  tearDown(() => repo.close());

  test('完整闭环：白癜风 → 计划 → 任务 → 完成 → 时间线', () async {
    const patientId = 'p1';
    await repo.savePatient(Patient(id: patientId, name: '张三'));

    // 1. 创建疾病。
    final disease = Disease(
      id: 'd-vitiligo',
      patientId: patientId,
      code: DiseaseCodes.vitiligo,
      name: '白癜风',
    );
    await repo.saveDisease(disease);

    var diseases = await repo.watchDiseases(patientId).first;
    expect(diseases.single.code, DiseaseCodes.vitiligo);

    // 2. 为该疾病创建管理计划。
    final plan = CarePlan(
      id: 'plan-1',
      patientId: patientId,
      diseaseId: disease.id,
      title: '医生建议的 308nm 光疗方案',
      status: CarePlanStatus.active,
    );
    await repo.saveCarePlan(plan);

    var plans = await repo.watchCarePlans(patientId).first;
    expect(plans.single.diseaseId, disease.id);

    // 3. 根据计划创建任务（来源可追踪：医生方案）。
    final dueAt = DateTime(2026, 9, 1, 19);
    final task = Task(
      id: 'task-1',
      patientId: patientId,
      diseaseId: disease.id,
      carePlanId: plan.id,
      title: '308nm 光疗',
      type: TaskType.treatment,
      source: TaskSource.doctorPlan,
      priority: TaskPriority.required,
      dueAt: dueAt,
    );
    await repo.saveTask(task);

    // 当日任务与疾病任务都能查到。
    var dayTasks = await repo.watchTasksForDay(patientId, dueAt).first;
    expect(dayTasks.single.id, 'task-1');
    var diseaseTasks = await repo.watchDiseaseTasks(patientId, disease.id).first;
    expect(diseaseTasks.single.carePlanId, plan.id);

    // 4. 执行任务：标记完成。
    await repo.completeTask(task.id, TaskStatus.completed);

    dayTasks = await repo.watchTasksForDay(patientId, dueAt).first;
    expect(dayTasks.single.status, TaskStatus.completed);
    expect(dayTasks.single.completedAt, isNotNull);

    // 完成后不再出现在疾病未完成任务中。
    diseaseTasks = await repo.watchDiseaseTasks(patientId, disease.id).first;
    expect(diseaseTasks, isEmpty);

    // 5. 完成任务沉淀为事件，进入时间线。
    final now = DateTime(2026, 9, 1, 19, 30);
    await repo.addEvent(HealthEvent(
      id: 'event-1',
      patientId: patientId,
      diseaseId: disease.id,
      type: EventType.taskCompleted,
      occurredAt: now,
      createdAt: now,
      title: task.title,
      source: EventSource.user,
      payload: {'task_id': task.id, 'task_source': task.source.name},
    ));

    // 6. 时间线：按疾病过滤能查到，且负载保留来源信息。
    final timeline = await repo
        .watchEvents(patientId, diseaseId: disease.id)
        .first;
    expect(timeline.single.type, EventType.taskCompleted);
    expect(timeline.single.payload['task_source'], 'doctorPlan');
  });
}
