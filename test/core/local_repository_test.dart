import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/core/storage/app_database.dart';
import 'package:zhiheng/core/storage/local_repository.dart';
import 'package:zhiheng/shared/domain/domain.dart';

void main() {
  late LocalRepository repo;

  setUp(() {
    repo = LocalRepository(AppDatabase(NativeDatabase.memory()));
  });

  tearDown(() => repo.close());

  group('Patient', () {
    test('savePatient 后 watchPatient 返回档案', () async {
      await repo.savePatient(Patient(id: 'p1', name: '张三'));
      final patient = await repo.watchPatient('p1').first;
      expect(patient, isNotNull);
      expect(patient!.name, '张三');
    });

    test('未建档时返回 null', () async {
      final patient = await repo.watchPatient('missing').first;
      expect(patient, isNull);
    });
  });

  group('Task', () {
    test('watchTasksForDay 只返回当天到期任务', () async {
      final day = DateTime(2026, 9, 1);
      await repo.saveTask(Task(
        id: 't-today',
        patientId: 'p1',
        title: '今日任务',
        type: TaskType.medication,
        source: TaskSource.userCreated,
        dueAt: DateTime(2026, 9, 1, 8),
      ));
      await repo.saveTask(Task(
        id: 't-tomorrow',
        patientId: 'p1',
        title: '明日任务',
        type: TaskType.measurement,
        source: TaskSource.userCreated,
        dueAt: DateTime(2026, 9, 2, 8),
      ));

      final tasks = await repo.watchTasksForDay('p1', day).first;
      expect(tasks.map((t) => t.id), ['t-today']);
    });

    test('completeTask 将任务标记完成并写入完成时间', () async {
      await repo.saveTask(Task(
        id: 't1',
        patientId: 'p1',
        title: '用药',
        type: TaskType.medication,
        source: TaskSource.doctorPlan,
        dueAt: DateTime(2026, 9, 1, 8),
      ));

      await repo.completeTask('t1', TaskStatus.completed);

      final tasks = await repo.watchTasksForDay(
        'p1',
        DateTime(2026, 9, 1),
      ).first;
      expect(tasks.single.status, TaskStatus.completed);
      expect(tasks.single.completedAt, isNotNull);
    });
  });

  group('Event 时间线', () {
    test('addEvent 追加、按发生时间倒序返回', () async {
      final earlier = DateTime(2026, 8, 30, 9);
      final later = DateTime(2026, 9, 1, 9);

      await repo.addEvent(HealthEvent(
        id: 'e-early',
        patientId: 'p1',
        type: EventType.measurement,
        occurredAt: earlier,
        createdAt: earlier,
        title: '空腹血糖 6.8',
        payload: {'metric': 'fasting_glucose', 'value': 6.8},
      ));
      await repo.addEvent(HealthEvent(
        id: 'e-late',
        patientId: 'p1',
        type: EventType.medication,
        occurredAt: later,
        createdAt: later,
        title: '二甲双胍 500mg',
      ));

      final events = await repo.watchEvents('p1').first;
      expect(events.map((e) => e.id), ['e-late', 'e-early']);
      // payload 往返不丢失（§7）。
      expect(events[1].payload['value'], 6.8);
    });

    test('按事件类型过滤', () async {
      final now = DateTime(2026, 9, 1, 9);
      await repo.addEvent(HealthEvent(
        id: 'e1',
        patientId: 'p1',
        type: EventType.measurement,
        occurredAt: now,
        createdAt: now,
      ));
      await repo.addEvent(HealthEvent(
        id: 'e2',
        patientId: 'p1',
        type: EventType.treatment,
        occurredAt: now,
        createdAt: now,
      ));

      final treatments = await repo
          .watchEvents('p1', type: EventType.treatment)
          .first;
      expect(treatments.map((e) => e.id), ['e2']);
    });

    test('按疾病过滤', () async {
      final now = DateTime(2026, 9, 1, 9);
      await repo.addEvent(HealthEvent(
        id: 'vitiligo-event',
        patientId: 'p1',
        diseaseId: 'd-vitiligo',
        type: EventType.treatment,
        occurredAt: now,
        createdAt: now,
      ));
      await repo.addEvent(HealthEvent(
        id: 'diabetes-event',
        patientId: 'p1',
        diseaseId: 'd-diabetes',
        type: EventType.measurement,
        occurredAt: now,
        createdAt: now,
      ));

      final vitiligoEvents = await repo
          .watchEvents('p1', diseaseId: 'd-vitiligo')
          .first;
      expect(vitiligoEvents.map((e) => e.id), ['vitiligo-event']);
    });
  });
}
