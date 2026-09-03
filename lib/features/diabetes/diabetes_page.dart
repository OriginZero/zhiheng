import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';

import '../../shared/domain/domain.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/glass/glass.dart';
import '../../shared/widgets/trend_chart.dart';
import '../disease/phototherapy_trend_section.dart';
import 'glucose_completion_sheet.dart';
import 'glucose_task_flow.dart';

/// 糖尿病专属首页（P0：血糖监测 + 低血糖预警 + 趋势预览）。
///
/// 展示今日血糖任务（空腹 / 餐后2小时 / 睡前）、快速记录入口、
/// 低血糖预警（最近一次 <3.9 mmol/L 时高亮）、血糖趋势预览。
///
/// 数据驱动：任务完成时通过 [TaskSupplement]（schema =
/// `diabetes.glucose.reading.v1`）记录读数，时间线事件同步沉淀，
/// 趋势图从事件 payload 提取数值。
class DiabetesPage extends ConsumerWidget {
  const DiabetesPage({super.key, required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(diseaseTasksProvider(diseaseId));
    final events = ref.watch(timelineEventsProvider(
      TimelineFilter(diseaseId: diseaseId),
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('血糖管理')),
      body: ListView(
        padding: EdgeInsets.all(SpacingTokens.x5),
        children: [
          // 低血糖预警（最近一次 <3.9 mmol/L）
          _HypoBanner(events: events.value),
          SizedBox(height: SpacingTokens.x4),

          // 今日血糖任务
          Text('今日血糖', style: context.headlineStyle),
          SizedBox(height: SpacingTokens.x2),
          _TodayGlucoseTasks(tasks: tasks.value),
          SizedBox(height: SpacingTokens.x5),

          // 快速记录
          Text('快速记录', style: context.headlineStyle),
          SizedBox(height: SpacingTokens.x2),
          _QuickRecord(diseaseId: diseaseId),
          SizedBox(height: SpacingTokens.x5),

          // 血糖趋势
          Text('血糖趋势', style: context.headlineStyle),
          SizedBox(height: SpacingTokens.x2),
          _GlucoseTrend(events: events.value),
        ],
      ),
    );
  }
}

/// 低血糖预警横幅（最近一次 <3.9 mmol/L 时显示）。
class _HypoBanner extends StatelessWidget {
  const _HypoBanner({required this.events});

  final List<HealthEvent>? events;

  /// 从事件列表中提取最近一次低血糖读数（<3.9 mmol/L）。
  double? _getLatestHypoValue() {
    final evts = events;
    if (evts == null) return null;
    for (final event in evts) {
      final value = trendValueFromEvent(event);
      if (value != null && value < kHypoglycemiaThreshold) {
        return value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hypoValue = _getLatestHypoValue();
    if (hypoValue == null) return const SizedBox.shrink();

    final colors = Theme.of(context).extension<ColorTokens>()!;
    final isSevere = hypoValue < kSevereHypoglycemiaThreshold;
    final color = isSevere ? colors.critical : colors.warning;

    return Container(
      padding: EdgeInsets.all(SpacingTokens.x3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: RadiusTokens.largeShape,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isSevere ? Icons.error_outline : Icons.warning_amber_outlined,
            color: color,
          ),
          SizedBox(width: SpacingTokens.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSevere ? '严重低血糖记录' : '低血糖记录',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '最近一次记录 $hypoValue mmol/L（<3.9），请关注后续变化。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 今日血糖任务列表（空腹 / 餐后2小时 / 睡前）。
class _TodayGlucoseTasks extends StatelessWidget {
  const _TodayGlucoseTasks({required this.tasks});

  final List<Task>? tasks;

  @override
  Widget build(BuildContext context) {
    final glucoseTasks = (tasks ?? const <Task>[])
        .where((t) => isGlucoseTask(t) && !t.isDone)
        .toList();

    if (glucoseTasks.isEmpty) {
      return GlassCard(
        child: Text(
          '今日血糖任务已完成或尚未创建。'
          '在「管理计划」中创建血糖监测模板可自动生成每日任务。',
          style: context.secondaryLabelStyle,
        ),
      );
    }

    return Column(
      children: [
        for (final task in glucoseTasks) _GlucoseTaskTile(task: task),
      ],
    );
  }
}

/// 单个血糖任务卡片。
class _GlucoseTaskTile extends ConsumerWidget {
  const _GlucoseTaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: textTheme.bodyLarge),
                SizedBox(height: SpacingTokens.x1),
                Text(
                  DateFormat('HH:mm').format(task.dueAt),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: RadiusTokens.pillShape,
            onTap: () => completeGlucoseTaskFlow(
              context,
              ref,
              task,
            ),
            child: Padding(
              padding: EdgeInsets.all(SpacingTokens.x2),
              child: Icon(
                Icons.radio_button_unchecked,
                color: colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 快速记录入口（不依赖任务，直接记录一次血糖）。
class _QuickRecord extends ConsumerWidget {
  const _QuickRecord({required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              '记录一次血糖（不关联任务）',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          GlassButton(
            type: GlassButtonType.glass,
            icon: Icons.add,
            onPressed: () => _showQuickRecord(context, ref),
            child: const Text('记录'),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuickRecord(BuildContext context, WidgetRef ref) async {
    // 快速记录：创建一个虚拟任务用于流程复用
    final dummyTask = Task(
      id: 'quick-record',
      patientId: localPatientId,
      diseaseId: diseaseId,
      title: '快速记录',
      type: TaskType.measurement,
      source: TaskSource.userCreated,
      priority: TaskPriority.suggested,
      dueAt: DateTime.now(),
    );
    if (!context.mounted) return;
    final result = await GlucoseCompletionSheet.show(context, task: dummyTask);
    if (result == null || !context.mounted) return;

    // 直接写入事件（不关联任务）
    final reading = glucoseReadingFrom(result.supplement);
    if (reading != null) {
      final now = DateTime.now();
      await ref.read(repositoryProvider).addEvent(
            HealthEvent(
              id: newId(),
              patientId: localPatientId,
              diseaseId: diseaseId,
              type: EventType.measurement,
              occurredAt: now,
              createdAt: now,
              title: '${reading.context.labelZh} ${reading.value} mmol/L',
              source: EventSource.user,
              payload: {
                'metric': 'glucose',
                'context': reading.context.name,
                'value': reading.value,
                'unit': 'mmol/L',
                'isHypo': reading.isHypo,
              },
              notes: result.notes,
            ),
          );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已记录血糖')),
    );
  }
}

/// 血糖趋势预览（复用通用趋势组件 + 低血糖参考线）。
class _GlucoseTrend extends StatelessWidget {
  const _GlucoseTrend({required this.events});

  final List<HealthEvent>? events;

  @override
  Widget build(BuildContext context) {
    final evts = events ?? const <HealthEvent>[];
    final glucoseEvents = evts.where((e) {
      // 从 payload 中提取血糖值（兼容任务完成事件和直接测量事件）
      final value = trendValueFromEvent(e);
      return value != null;
    }).toList();

    if (glucoseEvents.isEmpty) {
      return const GlassCard(
        child: EmptyState(
          icon: Icons.show_chart,
          title: '还没有血糖数据',
          message: '记录几次血糖后，这里会显示趋势。',
        ),
      );
    }

    final points = buildMeasurementTrendPoints(glucoseEvents);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('近 30 次', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: SpacingTokens.x2),
          SizedBox(
            height: 120,
            child: TrendChart(
              points: points,
              // 低血糖参考线（3.9 mmol/L）：低于此线为低血糖范围
              targetMin: kHypoglycemiaThreshold,
            ),
          ),
        ],
      ),
    );
  }
}
