import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/shared/domain/domain.dart';

void main() {
  group('GlucoseContext', () {
    test('labelZh 返回正确中文', () {
      expect(GlucoseContext.fasting.labelZh, '空腹');
      expect(GlucoseContext.preMeal.labelZh, '餐前');
      expect(GlucoseContext.postMeal.labelZh, '餐后2小时');
      expect(GlucoseContext.bedtime.labelZh, '睡前');
      expect(GlucoseContext.night.labelZh, '夜间');
      expect(GlucoseContext.other.labelZh, '其他');
    });
  });

  group('GlucoseMethod', () {
    test('labelZh 返回正确中文', () {
      expect(GlucoseMethod.fingerstick.labelZh, '指尖血糖');
      expect(GlucoseMethod.cgm.labelZh, 'CGM');
      expect(GlucoseMethod.hospital.labelZh, '医院检测');
    });
  });

  group('GlucoseReading', () {
    test('isHypo 自动判定 <3.9', () {
      expect(
        GlucoseReading(
          context: GlucoseContext.fasting,
          value: 3.8,
        ).isHypo,
        true,
      );
      expect(
        GlucoseReading(
          context: GlucoseContext.fasting,
          value: 3.9,
        ).isHypo,
        false,
      );
      expect(
        GlucoseReading(
          context: GlucoseContext.fasting,
          value: 6.0,
        ).isHypo,
        false,
      );
    });

    test('isSevereHypo 自动判定 <3.0', () {
      expect(
        GlucoseReading(
          context: GlucoseContext.fasting,
          value: 2.9,
        ).isSevereHypo,
        true,
      );
      expect(
        GlucoseReading(
          context: GlucoseContext.fasting,
          value: 3.0,
        ).isSevereHypo,
        false,
      );
    });

    test('toJson / tryFrom 往返', () {
      final reading = GlucoseReading(
        context: GlucoseContext.postMeal,
        value: 8.5,
        method: GlucoseMethod.cgm,
        symptoms: ['头晕'],
        exercise: true,
        notes: 'test',
      );
      final json = reading.toJson();
      final restored = GlucoseReading.tryFrom(json);
      expect(restored, isNotNull);
      expect(restored!.context, GlucoseContext.postMeal);
      expect(restored.value, 8.5);
      expect(restored.method, GlucoseMethod.cgm);
      expect(restored.symptoms, ['头晕']);
      expect(restored.exercise, true);
      expect(restored.notes, 'test');
    });

    test('tryFrom 非法输入返回 null', () {
      expect(GlucoseReading.tryFrom(null), isNull);
      expect(GlucoseReading.tryFrom({}), isNull);
      expect(GlucoseReading.tryFrom({'context': 'invalid'}), isNull);
    });
  });

  group('kGlucoseReadingSchema', () {
    test('schema 常量', () {
      expect(kGlucoseReadingSchema, 'diabetes.glucose.reading.v1');
    });
  });

  group('glucoseReadingFrom', () {
    test('从 TaskSupplement 提取', () {
      final reading = GlucoseReading(
        context: GlucoseContext.fasting,
        value: 5.6,
      );
      final supplement = TaskSupplement(
        schema: kGlucoseReadingSchema,
        content: reading.toJson(),
      );
      final extracted = glucoseReadingFrom(supplement);
      expect(extracted, isNotNull);
      expect(extracted!.value, 5.6);
    });

    test('非血糖 schema 返回 null', () {
      final supplement = TaskSupplement(
        schema: 'other.schema',
        content: {},
      );
      expect(glucoseReadingFrom(supplement), isNull);
    });
  });

  group('glucoseReadingSummaryZh', () {
    test('生成中文摘要', () {
      final reading = GlucoseReading(
        context: GlucoseContext.fasting,
        value: 6.8,
      );
      final supplement = TaskSupplement(
        schema: kGlucoseReadingSchema,
        content: reading.toJson(),
      );
      expect(
        glucoseReadingSummaryZh(supplement),
        '空腹 6.8 mmol/L',
      );
    });

    test('低血糖时追加标记', () {
      final reading = GlucoseReading(
        context: GlucoseContext.fasting,
        value: 3.5,
      );
      final supplement = TaskSupplement(
        schema: kGlucoseReadingSchema,
        content: reading.toJson(),
      );
      expect(
        glucoseReadingSummaryZh(supplement),
        '空腹 3.5 mmol/L（低血糖）',
      );
    });

    test('无补充时回退到 fallbackNotes', () {
      expect(
        glucoseReadingSummaryZh(null, fallbackNotes: '用户备注'),
        '用户备注',
      );
    });
  });
}
