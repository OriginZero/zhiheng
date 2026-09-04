import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/forms/task_form_sheet.dart';
import '../../shared/widgets/task_sheet.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/event_record_sheet.dart';
import '../phototherapy/phototherapy_task_flow.dart';
import '../diabetes/diabetes_check_task_flow.dart';
import '../diabetes/glucose_task_flow.dart';

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
        SizedBox(height: SpacingTokens.x3),
        const _OverdueSection(),
        const _DiseaseSection(),
        SizedBox(height: SpacingTokens.x5),
        _SectionHeader(
          title: '今日管理',
          onAdd: () => _addTask(context, ref),
          onRecord: () => EventRecordSheet.show(context),
        ),
        SizedBox(height: SpacingTokens.x3),
        AsyncStatusView(
          value: todayTasks,
          emptyState: EmptyState(
            icon: Icons.today_outlined,
            title: '今天还没有任务',
            message:
                '建立管理计划后，每天的任务会在这里生成。\n'
                '也可以先手动添加一条今日任务。',
            action: FilledButton.tonalIcon(
              icon: const Icon(Icons.add),
              onPressed: () => _addTask(context, ref),
              label: const Text('添加任务'),
            ),
          ),
          builder: (tasks) => _TaskGroups(tasks: tasks),
        ),
        SizedBox(height: SpacingTokens.x6),
        Text('近期待办', style: context.headlineStyle),
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
              for (final task in tasks.take(3)) _UpcomingRow(task: task),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addTask(BuildContext context, WidgetRef ref) async {
    final draft = await TaskFormSheet.show(context);
    if (draft != null) {
      await saveTaskDraft(ref, draft);
    }
  }
}

/// 带添加按钮的分区标题。
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onAdd,
    this.onRecord,
  });

  final String title;
  final VoidCallback onAdd;

  /// 可选：「记录」入口（打开手动健康记录表单）。
  final VoidCallback? onRecord;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Text(title, style: context.headlineStyle)),
        if (onRecord != null) ...[
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: '记录',
            onPressed: onRecord,
            style: IconButton.styleFrom(
              foregroundColor: scheme.primary,
              backgroundColor: scheme.primary.withValues(alpha: 0.14),
            ),
          ),
          SizedBox(width: SpacingTokens.x2),
        ],
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: '添加任务',
          onPressed: onAdd,
          style: IconButton.styleFrom(
            foregroundColor: scheme.primary,
            backgroundColor: scheme.primary.withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }
}

/// 疾病区：快速进入各疾病的管理页（§32 疾病入口）。
class _DiseaseSection extends ConsumerWidget {
  const _DiseaseSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseases = ref.watch(diseasesProvider).value ?? const <Disease>[];
    final scheme = Theme.of(context).colorScheme;

    if (diseases.isEmpty) {
      return Card(
        child: InkWell(
          borderRadius: RadiusTokens.mediumShape,
          onTap: () => context.push('/diseases'),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.x4),
            child: Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 22,
                  color: scheme.primary,
                ),
                SizedBox(width: SpacingTokens.x3),
                Expanded(
                  child: Text(
                    '添加你在管理的疾病，开始建立管理计划',
                    style: context.secondaryBodyStyle,
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: scheme.outline),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: diseases.length + 1,
        separatorBuilder: (context, _) => SizedBox(width: SpacingTokens.x3),
        itemBuilder: (context, index) {
          if (index == diseases.length) {
            return _AddDiseaseCard();
          }
          return _DiseaseCard(disease: diseases[index]);
        },
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  const _DiseaseCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 180,
      child: Card(
        child: InkWell(
          borderRadius: RadiusTokens.mediumShape,
          onTap: () => context.push('/disease/${disease.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.x4,
              vertical: SpacingTokens.x3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 20,
                  color: scheme.primary,
                ),
                SizedBox(height: SpacingTokens.x2),
                Text(
                  disease.name,
                  style: context.labelBoldStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SpacingTokens.x1),
                Text(disease.status.labelZh, style: context.captionStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddDiseaseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 88,
      child: Card(
        child: InkWell(
          borderRadius: RadiusTokens.mediumShape,
          onTap: () => context.push('/diseases'),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.x4),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 22, color: scheme.primary),
                  SizedBox(height: SpacingTokens.x1),
                  Text('添加', style: context.captionStyle),
                ],
              ),
            ),
          ),
        ),
      ),
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
          Text('$greeting，$patientName', style: context.titleStyle),
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

/// 需要关注：逾期任务提醒（§10 首页关注区）。
///
/// 有逾期未完成任务时显示警告卡，最多列出 3 条标题；无逾期时不显示。
class _OverdueSection extends ConsumerWidget {
  const _OverdueSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = ref.watch(overdueTasksProvider).value ?? const <Task>[];
    if (overdue.isEmpty) {
      return const SizedBox.shrink();
    }
    // 逾期提醒属医疗警示语义色，仍走 ColorTokens.warning；其余一律 colorScheme。
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: SpacingTokens.x5),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 22,
                    color: colors.warning,
                  ),
                  SizedBox(width: SpacingTokens.x2),
                  Expanded(
                    child: Text(
                      '有 ${overdue.length} 个逾期未完成的任务',
                      style: context.labelBoldStyle,
                    ),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.x2),
              for (final task in overdue.take(3))
                Padding(
                  padding: EdgeInsets.only(bottom: SpacingTokens.x1),
                  child: Text(
                    '· ${task.title}',
                    style: context.secondaryBodyStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
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
    final required = tasks
        .where((t) => t.priority == TaskPriority.required)
        .toList();
    final suggested = tasks
        .where((t) => t.priority == TaskPriority.suggested)
        .toList();

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
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      child: InkWell(
        borderRadius: RadiusTokens.mediumShape,
        onTap: () => showTaskSheet(context, ref, task),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.x4),
          child: Row(
            children: [
              InkWell(
                borderRadius: RadiusTokens.pillShape,
                onTap: done
                    ? null
                    : () {
                        if (task.templateId == 'vitiligo.phototherapy') {
                          completePhototherapyTaskFlow(context, ref, task);
                        } else if (isDiabetesCheckTask(task)) {
                          completeDiabetesCheckTaskFlow(context, ref, task);
                        } else if (isGlucoseTask(task)) {
                          completeGlucoseTaskFlow(context, ref, task);
                        } else {
                          ref
                              .read(completeTaskProvider.notifier)
                              .complete(task);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.x2),
                  // 勾选完成态 primary；未选 outline（原 textTertiary 同值迁移）。
                  child: Icon(
                    done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done ? scheme.primary : scheme.outline,
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
                        color: done ? scheme.outline : null,
                      ),
                    ),
                    SizedBox(height: SpacingTokens.x1),
                    Row(
                      children: [
                        Icon(Icons.tag, size: 12, color: scheme.outline),
                        SizedBox(width: SpacingTokens.x1),
                        Text(
                          '${task.type.labelZh} · ${DateFormat('HH:mm').format(task.dueAt)}',
                          style: context.captionStyle,
                        ),
                        if (task.isRecurring) ...[
                          SizedBox(width: SpacingTokens.x2),
                          Icon(Icons.repeat, size: 12, color: scheme.primary),
                          Text(
                            task.recurrence.descriptionZh,
                            style: context.captionStyle.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // 任务来源标记（§10：来源必须可追踪）。
              _SourceBadge(source: task.source),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final TaskSource source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.x2,
        vertical: SpacingTokens.x1,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
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
    return Card(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.x4),
        child: Row(
          children: [
            Expanded(child: Text(task.title, style: context.bodyStyle)),
            Text(
              DateFormat('M/d HH:mm').format(task.dueAt),
              style: context.secondaryLabelStyle,
            ),
          ],
        ),
      ),
    );
  }
}
