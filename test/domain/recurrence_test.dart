import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/shared/domain/domain.dart';

/// 周期规则测试（开发文档 §43：规则必须有独立测试，含正常/边界/异常）。
void main() {
  group('nextOccurrence 每日', () {
    test('每天一次：次日同一时刻', () {
      const r = TaskRecurrence(frequency: RecurrenceFrequency.daily);
      final from = DateTime(2026, 9, 1, 19, 0);
      expect(nextOccurrence(r, from), DateTime(2026, 9, 2, 19, 0));
    });

    test('每 3 天一次', () {
      const r = TaskRecurrence(
          frequency: RecurrenceFrequency.daily, interval: 3);
      final from = DateTime(2026, 9, 1, 8, 30);
      expect(nextOccurrence(r, from), DateTime(2026, 9, 4, 8, 30));
    });
  });

  group('nextOccurrence 每周（光疗：周一/三/五）', () {
    final weekly = TaskRecurrence(
      frequency: RecurrenceFrequency.weekly,
      interval: 1,
      weekdays: [1, 3, 5], // 一三五
      anchor: DateTime(2026, 9, 1), // 周二（该周锚点）
    );

    test('周一完成后 → 周三', () {
      final from = DateTime(2026, 9, 7, 19, 0); // 周一
      expect(nextOccurrence(weekly, from), DateTime(2026, 9, 9, 19, 0));
    });

    test('周五完成后 → 下周一（跨周）', () {
      final from = DateTime(2026, 9, 11, 19, 0); // 周五
      expect(nextOccurrence(weekly, from), DateTime(2026, 9, 14, 19, 0));
    });

    test('每 2 周：锚点周内的周五完成后 → 隔一周的周一', () {
      final biweekly = TaskRecurrence(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        weekdays: [1, 3, 5],
        anchor: DateTime(2026, 9, 1), // 周二所在周为第 0 周
      );
      final from = DateTime(2026, 9, 4, 19, 0); // 第 0 周周五
      // 下一允许日：第 1 周周一/三/五都被 2 整除规则跳过 → 第 2 周周一。
      expect(nextOccurrence(biweekly, from), DateTime(2026, 9, 14, 19, 0));
    });
  });

  group('nextOccurrence 每月（HbA1c 每 3 个月）', () {
    test('9 月完成后 → 12 月同日', () {
      const r =
          TaskRecurrence(frequency: RecurrenceFrequency.monthly, interval: 3);
      final from = DateTime(2026, 9, 15, 9, 0);
      expect(nextOccurrence(r, from), DateTime(2026, 12, 15, 9, 0));
    });
  });

  group('周期结束（§44：疗程有终点）', () {
    test('超过 endAt 后抛错（链结束）', () {
      final r = TaskRecurrence(
        frequency: RecurrenceFrequency.daily,
        endAt: DateTime(2026, 9, 5),
      );
      final from = DateTime(2026, 9, 5, 19, 0);
      expect(() => nextOccurrence(r, from), throwsStateError);
    });

    test('endAt 当天仍可生成次日任务，次日超过则结束', () {
      final r = TaskRecurrence(
        frequency: RecurrenceFrequency.daily,
        endAt: DateTime(2026, 9, 6),
      );
      expect(
        nextOccurrence(r, DateTime(2026, 9, 5, 19, 0)),
        DateTime(2026, 9, 6, 19, 0),
      );
      expect(
        () => nextOccurrence(r, DateTime(2026, 9, 6, 19, 0)),
        throwsStateError,
      );
    });
  });

  group('firstOccurrence（链的首次任务日期）', () {
    test('周四启动每周一三五 → 本周五', () {
      const weekly = TaskRecurrence(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [1, 3, 5],
      );
      // 2026-09-10 是周四。
      expect(
        firstOccurrence(weekly, DateTime(2026, 9, 10)),
        DateTime(2026, 9, 11),
      );
    });

    test('周六启动每周一三五 → 下周一', () {
      const weekly = TaskRecurrence(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [1, 3, 5],
      );
      // 2026-09-12 是周六。
      expect(
        firstOccurrence(weekly, DateTime(2026, 9, 12)),
        DateTime(2026, 9, 14),
      );
    });

    test('异常：weekly 未指定星期几', () {
      const bad = TaskRecurrence(frequency: RecurrenceFrequency.weekly);
      expect(
        () => firstOccurrence(bad, DateTime(2026, 9, 10)),
        throwsStateError,
      );
    });
  });

  group('描述与序列化', () {
    test('descriptionZh 正确', () {
      const weekly = TaskRecurrence(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [1, 3, 5],
      );
      expect(weekly.descriptionZh, '每周 周一、周三、周五');

      const monthly =
          TaskRecurrence(frequency: RecurrenceFrequency.monthly, interval: 3);
      expect(monthly.descriptionZh, '每 3 个月');

      const daily = TaskRecurrence(frequency: RecurrenceFrequency.daily);
      expect(daily.descriptionZh, '每天');
    });

    test('weekdaysJson 往返', () {
      const weekly = TaskRecurrence(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [1, 3, 5],
      );
      expect(TaskRecurrence.weekdaysFromJson(weekly.weekdaysJson), [1, 3, 5]);
      expect(TaskRecurrence.weekdaysFromJson(null), isEmpty);
    });
  });
}
