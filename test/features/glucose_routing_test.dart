import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/features/diabetes/glucose_task_flow.dart';
import 'package:zhiheng/shared/domain/domain.dart';


void main() {
  group('isGlucoseTask', () {
    test('识别血糖任务模板', () {
      expect(isGlucoseTask(_fakeTask('diabetes.glucose.fasting')), true);
      expect(isGlucoseTask(_fakeTask('diabetes.glucose.postMeal')), true);
      expect(isGlucoseTask(_fakeTask('diabetes.glucose.bedtime')), true);
    });

    test('排除非血糖任务', () {
      expect(isGlucoseTask(_fakeTask('vitiligo.phototherapy')), false);
      expect(isGlucoseTask(_fakeTask('diabetes.hba1c')), false);
      expect(isGlucoseTask(_fakeTask('diabetes.annual')), false);
      expect(isGlucoseTask(_fakeTask('custom')), false);
      expect(isGlucoseTask(_fakeTask(null)), false);
    });
  });
}
Task _fakeTask(String? templateId) => Task(
      id: 'test',
      patientId: 'patient',
      title: '测试',
      type: TaskType.measurement,
      source: TaskSource.userCreated,
      dueAt: DateTime.now(),
      templateId: templateId,
    );
