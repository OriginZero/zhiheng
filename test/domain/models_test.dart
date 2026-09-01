import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/shared/domain/domain.dart';

void main() {
  group('Patient.ageYears', () {
    test('生日已过 → 满岁', () {
      final now = DateTime.now();
      final patient = Patient(
        id: 'p1',
        name: 'x',
        birthDate: DateTime(now.year - 30, 1, 1),
      );
      expect(patient.ageYears, 30);
    });

    test('生日未到 → 减一岁', () {
      final now = DateTime.now();
      final patient = Patient(
        id: 'p1',
        name: 'x',
        birthDate: DateTime(now.year - 30, 12, 31),
      );
      // 仅当生日确实在今天之后时才是 29。
      final expected =
          (now.month < 12 || (now.month == 12 && now.day < 31)) ? 29 : 30;
      expect(patient.ageYears, expected);
    });

    test('未填写生日 → null', () {
      const patient = Patient(id: 'p1', name: 'x');
      expect(patient.ageYears, isNull);
    });
  });

  group('领域模型不可变性约束', () {
    test('Task.copyWith 不改写未指定字段（历史事实不被覆盖，§44）', () {
      final original = Task(
        id: 't1',
        patientId: 'p1',
        title: '308nm 光疗',
        type: TaskType.treatment,
        source: TaskSource.doctorPlan,
        dueAt: DateTime(2026, 1, 1, 19),
      );

      final updated = original.copyWith(status: TaskStatus.completed);

      expect(updated.title, original.title);
      expect(updated.source, original.source);
      expect(updated.dueAt, original.dueAt);
      expect(updated.status, TaskStatus.completed);
      // 原对象不被修改。
      expect(original.status, TaskStatus.pending);
    });

    test('HealthEvent payload 默认可 JSON 序列化', () {
      final event = HealthEvent(
        id: 'e1',
        patientId: 'p1',
        type: EventType.measurement,
        occurredAt: DateTime(2026, 9, 1),
        createdAt: DateTime(2026, 9, 1),
        payload: {'value': 6.8, 'unit': 'mmol/L'},
      );
      expect(event.payloadJson, contains('mmol/L'));
    });
  });

  group('中文标签存在（产品语言为简体中文，§55）', () {
    test('疾病编码有中文名', () {
      expect(DiseaseCodes.displayName(DiseaseCodes.vitiligo), '白癜风');
      expect(
        DiseaseCodes.displayName(DiseaseCodes.type2Diabetes),
        '2 型糖尿病',
      );
    });

    test('任务来源标签可追踪（§10）', () {
      expect(TaskSource.doctorPlan.labelZh, '医生方案');
      expect(TaskSource.userCreated.labelZh, '自建');
    });
  });
}
