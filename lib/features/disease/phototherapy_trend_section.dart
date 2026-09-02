import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/trend_chart.dart';

const _noDoseState = EmptyState(
  icon: Icons.show_chart,
  title: '还没有足够数据',
  message: '完成几次光疗并记录剂量后，这里会显示剂量趋势。',
);

const _noMeasurementState = EmptyState(
  icon: Icons.monitor_heart_outlined,
  title: '还没有测量数据',
  message: '记录几次测量后，这里会显示数值趋势。',
);

/// 从测量事件 payload 提取数值。
///
/// 测量事件 payload 形如 {"metric": "空腹血糖", "value": 6.8, "unit": "mmol/L"}；
/// 经数据库 JSON 往返后 [HealthEvent.payload] 的 value 可能是 double 或 int，
/// 这里按 num 统一提取，并兜底兼容字符串数值。
double? trendValueFromEvent(HealthEvent event) {
  final raw = event.payload['value'];
  if (raw is num) return raw.toDouble();
  if (raw is String) return double.tryParse(raw);
  return null;
}

/// 光疗剂量 → 趋势点。
///
/// [records] 按时间倒序（仓储顺序）：过滤剂量非空记录后取最近 [limit] 条，
/// 再反转成时间正序供图表从左（早）到右（晚）绘制；
/// 红斑 / 水疱记录标记为异常点。
List<TrendPoint> buildDoseTrendPoints(
  List<PhototherapyRecord> records, {
  int limit = 30,
}) {
  final withDose = <(PhototherapyRecord, double)>[];
  for (final record in records) {
    final dose = record.dose;
    if (dose != null && withDose.length < limit) {
      withDose.add((record, dose));
    }
  }
  return withDose.reversed
      .map(
        (pair) => TrendPoint(
          label: DateFormat('M/d').format(pair.$1.occurredAt),
          value: pair.$2,
          isAbnormal: pair.$1.erythema || pair.$1.blister,
        ),
      )
      .toList();
}

/// 测量事件 → 趋势点。
///
/// [events] 按时间倒序（仓储顺序）：过滤出 payload 数值有效的事件后取最近
/// [limit] 条，再反转成时间正序。
List<TrendPoint> buildMeasurementTrendPoints(
  List<HealthEvent> events, {
  int limit = 30,
}) {
  final withValue = <(HealthEvent, double)>[];
  for (final event in events) {
    final value = trendValueFromEvent(event);
    if (value != null && withValue.length < limit) {
      withValue.add((event, value));
    }
  }
  return withValue.reversed
      .map(
        (pair) => TrendPoint(
          label: DateFormat('M/d').format(pair.$1.occurredAt),
          value: pair.$2,
        ),
      )
      .toList();
}

/// 光疗剂量趋势区（§33：每个图表回答一个问题）。
class PhototherapyTrendSection extends ConsumerWidget {
  const PhototherapyTrendSection({super.key, required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(phototherapyRecordsProvider(diseaseId));
    return _TrendSection(
      title: '剂量趋势',
      child: AsyncStatusView(
        value: records,
        emptyState: _noDoseState,
        builder: (list) {
          final points = buildDoseTrendPoints(list);
          if (points.isEmpty) return _noDoseState;
          return TrendChart(points: points);
        },
      ),
    );
  }
}

/// 测量趋势区（§33）。
class MeasurementTrendSection extends ConsumerWidget {
  const MeasurementTrendSection({super.key, required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(
      timelineEventsProvider(
        TimelineFilter(diseaseId: diseaseId, type: EventType.measurement),
      ),
    );
    return _TrendSection(
      title: '测量趋势',
      child: AsyncStatusView(
        value: events,
        emptyState: _noMeasurementState,
        builder: (list) {
          final points = buildMeasurementTrendPoints(list);
          if (points.isEmpty) return _noMeasurementState;
          return TrendChart(points: points);
        },
      ),
    );
  }
}

/// 趋势区公共布局：标题 + 图表（页面级间距由外部负责）。
class _TrendSection extends StatelessWidget {
  const _TrendSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.headlineStyle),
        SizedBox(height: SpacingTokens.x2),
        child,
      ],
    );
  }
}
