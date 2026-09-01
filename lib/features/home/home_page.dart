import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/task_providers.dart';
import '../../app/providers/core_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/glass/glass.dart';

/// 首页：Today（开发文档 §31）。
///
/// 回答三个问题：今天需要做什么？最近状态怎么样？有什么需要关注？
/// 首页不是 Dashboard，不堆数据。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasks = ref.watch(todayTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider);
    final patient = ref.watch(currentPatientNameProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.x5,
        SpacingTokens.x2,
        SpacingTokens.x5,
        SpacingTokens.x6,
      ),
      children: [
        _Greeting(patientName: patient),
        SizedBox(height: SpacingTokens.x5),
        Text('今日管理', style: context.headlineStyle),
        SizedBox(height: SpacingTokens.x3),
        AsyncStatusView(
          value: todayTasks,
          emptyState: const EmptyState(
            icon: Icons.today_outlined,
            title: '今天还没有任务',
            message: '建立管理计划后，每天的任务会在这里生成。\n'
                '也可以先手动添加一条今日任务。',
          ),
          builder: (tasks) => _TaskGroups(tasks: tasks),
        ),
        SizedBox(height: SpacingTokens.x6),
        Text('即将到期', style: context.headlineStyle),
        SizedBox(height: SpacingTokens.x3),
        AsyncStatusView(
          value: upcomingTasks,
          emptyState: const EmptyState(
            icon: Icons.upcoming_outlined,
            title: '近期没有待办',
            message: '未来 7 天的任务会显示在这里。',
          ),
          builder: (tasks) => Column(
            children: [
              for (final task in tasks.take(3))
                _UpcomingRow(task: task),
            ],
          ),
        ),
      ],
    );
  }
}

/// 问候语（当前患者名字）。
final currentPatientNameProvider = Provider<String>((ref) {
  final patient = ref.watch(currentPatientProvider).value;
  return patient?.name ?? '你好';
});

class _Greeting extends StatelessWidget {
  const _Greeting({required this.patientName});

  final String patientName;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = switch (hour) {
      < 5 => '夜深了',
      < 11 => '早上好',
      < 13 => '中午好',
      < 18 => '下午好',
      _ => '晚上好',
    };

    return Padding(
      padding: EdgeInsets.symmetric(vertical: SpacingTokens.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting，$patientName',
            style: context.displayStyle.copyWith(
              fontSize: TypographyTokens.titleSize,
            ),
          ),
          SizedBox(height: SpacingTokens.x1),
          Text(
            DateFormat('M月d日 EEEE', 'zh_CN').format(DateTime.now()),
            style: context.secondaryLabelStyle,
          ),
        ],
      ),
    );
  }
}

/// 任务分组：必须完成 / 建议完成（§10）。
class _TaskGroups extends StatelessWidget {
  const _TaskGroups({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final required =
        tasks.where((t) => t.priority == TaskPriority.required).toList();
    final suggested =
        tasks.where((t) => t.priority == TaskPriority.suggested).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (required.isNotEmpty) ...[
          _GroupLabel(label: TaskPriority.required.labelZh),
          for (final task in required) _TaskTile(task: task),
        ],
        if (suggested.isNotEmpty) ...[
          SizedBox(height: SpacingTokens.x4),
          _GroupLabel(label: TaskPriority.suggested.labelZh),
          for (final task in suggested) _TaskTile(task: task),
        ],
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Text(label, style: context.secondaryLabelStyle),
    );
  }
}

/// 任务行：勾选完成 → 写入事件（闭环）。
class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = task.isDone;

    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Row(
        children: [
          InkWell(
            borderRadius: RadiusTokens.pillShape,
            onTap: done
                ? null
                : () => ref
                    .read(completeTaskProvider.notifier)
                    .complete(task),
            child: Padding(
              padding: EdgeInsets.all(SpacingTokens.x2),
              child: Icon(
                done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: done
                    ? Theme.of(context).extension<ColorTokens>()!.success
                    : Theme.of(context).extension<ColorTokens>()!.textTertiary,
              ),
            ),
          ),
          SizedBox(width: SpacingTokens.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: context.bodyBoldStyle.copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done
                        ? Theme.of(context).extension<ColorTokens>()!.textTertiary
                        : null,
                  ),
                ),
                SizedBox(height: SpacingTokens.x1),
                Row(
                  children: [
                    Icon(Icons.tag, size: 12,
                        color: Theme.of(context).extension<ColorTokens>()!.textTertiary),
                    SizedBox(width: SpacingTokens.x1),
                    Text(
                      '${task.type.labelZh} · ${DateFormat('HH:mm').format(task.dueAt)}',
                      style: context.captionStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 任务来源标记（§10：来源必须可追踪）。
          _SourceBadge(source: task.source),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final TaskSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.x2,
        vertical: SpacingTokens.x1,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<ColorTokens>()!.divider,
        borderRadius: RadiusTokens.pillShape,
      ),
      child: Text(source.labelZh, style: context.captionStyle),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Row(
        children: [
          Expanded(
            child: Text(task.title, style: context.bodyStyle),
          ),
          Text(
            DateFormat('M/d HH:mm').format(task.dueAt),
            style: context.secondaryLabelStyle,
          ),
        ],
      ),
    );
  }
}
