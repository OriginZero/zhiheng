import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zhiheng/core/theme/theme.dart';
import 'package:zhiheng/features/disease/phototherapy_trend_section.dart';
import 'package:zhiheng/shared/domain/domain.dart';
import 'package:zhiheng/shared/widgets/trend_chart.dart';

/// 趋势分析测试（§33）。
///
/// - TrendChart 空 / 单点 / 多点 / 异常点渲染不崩；
/// - 测量事件 payload 数值提取；
/// - 光疗剂量 / 测量事件 → 趋势点构建（过滤、最近 30 条、时间正序）；
/// - tooltip 点击交互不崩。
void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: Center(child: child)),
      );

  group('TrendChart 渲染', () {
    testWidgets('空列表显示占位且不抛异常', (tester) async {
      await tester.pumpWidget(wrap(const TrendChart(points: [])));

      expect(find.text('暂无趋势数据'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('单点居中渲染不抛异常', (tester) async {
      await tester.pumpWidget(wrap(const TrendChart(
        points: [TrendPoint(label: '9/1', value: 0.4)],
      )));

      expect(tester.takeException(), isNull);
    });

    testWidgets('多点渲染不抛异常', (tester) async {
      await tester.pumpWidget(wrap(TrendChart(
        points: const [
          TrendPoint(label: '9/1', value: 0.4),
          TrendPoint(label: '9/2', value: 0.6),
          TrendPoint(label: '9/3', value: 0.5),
          TrendPoint(label: '9/4', value: 0.8),
        ],
      )));

      expect(tester.takeException(), isNull);
    });

    testWidgets('异常点渲染不抛异常', (tester) async {
      await tester.pumpWidget(wrap(TrendChart(
        points: const [
          TrendPoint(label: '9/1', value: 0.4),
          TrendPoint(label: '9/2', value: 0.9, isAbnormal: true),
          TrendPoint(label: '9/3', value: 0.5),
        ],
      )));

      expect(tester.takeException(), isNull);
    });

    testWidgets('值全同时 y 轴刻度（该值 ±1）不抛异常', (tester) async {
      await tester.pumpWidget(wrap(TrendChart(
        points: const [
          TrendPoint(label: '9/1', value: 0.5),
          TrendPoint(label: '9/2', value: 0.5),
          TrendPoint(label: '9/3', value: 0.5),
        ],
      )));

      expect(tester.takeException(), isNull);
    });

    testWidgets('目标范围淡色带渲染不抛异常', (tester) async {
      await tester.pumpWidget(wrap(TrendChart(
        points: const [
          TrendPoint(label: '9/1', value: 0.4),
          TrendPoint(label: '9/2', value: 0.8),
        ],
        targetMin: 0.2,
        targetMax: 0.6,
      )));

      expect(tester.takeException(), isNull);
    });

    testWidgets('点击最近点显示 tooltip 且不抛异常', (tester) async {
      await tester.pumpWidget(wrap(TrendChart(
        points: const [
          TrendPoint(label: '9/1', value: 0.4),
          TrendPoint(label: '9/2', value: 0.8),
          TrendPoint(label: '9/3', value: 0.6),
        ],
      )));

      await tester.tap(find.byType(TrendChart));
      await tester.pump();

      // 点击图表中部 → 最近点为中间的 9/2。
      expect(find.textContaining('9/2 · 0.8'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('趋势数据提取', () {
    HealthEvent event({
      required String id,
      Object? value,
      DateTime? occurredAt,
    }) {
      final at = occurredAt ?? DateTime(2026, 9, 1);
      return HealthEvent(
        id: id,
        patientId: 'p1',
        type: EventType.measurement,
        occurredAt: at,
        createdAt: at,
        payload: value == null
            ? const {'metric': '空腹血糖'}
            : {'metric': '空腹血糖', 'value': value},
      );
    }

    test('trendValueFromEvent：提取 payload 数值（double/int/字符串）', () {
      expect(
        trendValueFromEvent(event(id: '1', value: 6.8)),
        6.8,
      );
      // JSON 往返后 7.0 可能变为 int 7，仍应提取。
      expect(
        trendValueFromEvent(event(id: '2', value: 7)),
        7.0,
      );
      // 字符串数值兜底。
      expect(
        trendValueFromEvent(event(id: '3', value: '6.8')),
        6.8,
      );
      // 缺失 / 非数值 → null。
      expect(trendValueFromEvent(event(id: '4')), isNull);
      expect(trendValueFromEvent(event(id: '5', value: 'abc')), isNull);
    });

    test('buildMeasurementTrendPoints：过滤无效数值、取最近 30 条、时间正序', () {
      final events = [
        for (var i = 0; i < 35; i++)
          event(
            id: 'e$i',
            value: i % 7 == 0 ? null : i / 10,
            occurredAt: DateTime(2026, 8, 1).add(Duration(days: i)),
          ),
      ];
      // 仓储返回时间倒序。
      final desc = events.reversed.toList();

      final points = buildMeasurementTrendPoints(desc);
      // 35 条中 5 条无数值 → 30 条全部保留。
      expect(points.length, 30);
      // 时间正序：最旧在前。
      expect(points.first.value, 0.1);
      expect(points.first.label, '8/2');
      expect(points.last.value, 3.4);

      // 只取最近 limit 条（倒序中的前 10 条有效记录）。
      final limited = buildMeasurementTrendPoints(desc, limit: 10);
      expect(limited.length, 10);
      expect(limited.first.value, 2.4);
      expect(limited.last.value, 3.4);
    });

    test('buildDoseTrendPoints：过滤空剂量、异常标记、取最近 30 条、时间正序', () {
      final records = [
        for (var i = 0; i < 35; i++)
          PhototherapyRecord(
            id: 'r$i',
            patientId: 'p1',
            diseaseId: 'd1',
            occurredAt: DateTime(2026, 8, 1).add(Duration(days: i)),
            dose: i % 5 == 0 ? null : i / 10,
            erythema: i == 33,
            blister: i == 21,
          ),
      ];
      // 仓储返回时间倒序。
      final desc = records.reversed.toList();

      final points = buildDoseTrendPoints(desc);
      // 35 条中 7 条无剂量 → 28 条有剂量。
      expect(points.length, 28);
      // 时间正序。
      expect(points.first.value, 0.1);
      expect(points.first.label, '8/2');
      expect(points.last.value, 3.4);
      // 红斑（i=33）与水疱（i=21）记录标记为异常。
      expect(points.where((p) => p.isAbnormal).length, 2);

      // 只取最近 limit 条。
      final limited = buildDoseTrendPoints(desc, limit: 10);
      expect(limited.length, 10);
      expect(limited.first.value, 2.3);
      expect(limited.last.value, 3.4);
      expect(limited.where((p) => p.isAbnormal).length, 1);
    });
  });
}
