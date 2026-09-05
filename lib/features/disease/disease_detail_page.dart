import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../features/task/disease_templates.dart';
import '../phototherapy/phototherapy_task_flow.dart';
import '../diabetes/diabetes_check_task_flow.dart';
import '../diabetes/glucose_task_flow.dart';

import '../../shared/domain/domain.dart';
import '../../shared/forms/task_form_sheet.dart';
import '../../shared/widgets/task_sheet.dart';
import 'phototherapy_trend_section.dart';
import '../photo/photo_timeline_section.dart';
import '../../shared/widgets/async_status_view.dart';
import '../phototherapy/phototherapy_form_sheet.dart';

/// 疾病详情页：指南模板、当前计划、未完成任务、添加任务入口。
///
/// 通过路由参数 [diseaseId] 定位。
class DiseaseDetailPage extends ConsumerWidget {
  const DiseaseDetailPage({super.key, required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diseases = ref.watch(diseasesProvider).value ?? const <Disease>[];
    final disease = diseases.where((d) => d.id == diseaseId).firstOrNull;

    if (disease == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.search_off,
          title: '未找到该疾病',
          message: '它可能已被删除。',
        ),
      );
    }

    final tasks = ref.watch(diseaseTasksProvider(diseaseId));
    final plans = ref.watch(diseaseCarePlansProvider(diseaseId));
    final templates = DiseaseTemplates.forDisease(disease.code);

    return Scaffold(
      appBar: AppBar(title: Text(disease.name)),
      body: ListView(
        padding: EdgeInsets.all(SpacingTokens.x5),
        children: [
          _StatusCard(disease: disease),
          if (templates.isNotEmpty) ...[
            SizedBox(height: SpacingTokens.x5),
            Text('指南推荐模板', style: context.headlineStyle),
            SizedBox(height: SpacingTokens.x2),
            Text(
              '模板依据已发布的诊疗指南预填周期，具体剂量与频率以医生方案为准。',
              style: context.captionStyle,
            ),
            SizedBox(height: SpacingTokens.x2),
            for (final template in templates)
              _TemplateCard(template: template, disease: disease),
          ],
          SizedBox(height: SpacingTokens.x5),
          _SectionHeader(
            title: '管理计划',
            onAdd: () => _showPlanSheet(context, ref, disease),
          ),
          SizedBox(height: SpacingTokens.x2),
          if (plans.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.x4),
                child: Text(
                  '还没有管理计划。为这个疾病制定计划后，可以据此生成每日任务。',
                  style: context.secondaryLabelStyle,
                ),
              ),
            )
          else
            for (final plan in plans) _PlanTile(plan: plan),
          SizedBox(height: SpacingTokens.x5),
          _SectionHeader(
            title: '待办任务',
            onAdd: () => _addTask(context, ref, disease),
          ),
          SizedBox(height: SpacingTokens.x2),
          AsyncStatusView(
            value: tasks,
            emptyState: EmptyState(
              icon: Icons.check_circle_outline,
              title: '暂无待办任务',
              message: '添加一条任务，它会出现在首页今日管理中。',
              action: FilledButton.tonalIcon(
                onPressed: () => _addTask(context, ref, disease),
                icon: const Icon(Icons.add),
                label: const Text('添加任务'),
              ),
            ),
            builder: (list) => Column(
              children: [for (final task in list) _TaskTile(task: task)],
            ),
          ),
          if (disease.code == DiseaseCodes.vitiligo) ...[
            SizedBox(height: SpacingTokens.x5),
            _SectionHeader(
              title: '光疗记录',
              onAdd: () => _addPhototherapyRecord(context, ref, disease),
            ),
            SizedBox(height: SpacingTokens.x2),
            AsyncStatusView(
              value: ref.watch(phototherapyRecordsProvider(disease.id)),
              emptyState: const EmptyState(
                icon: Icons.flash_on_outlined,
                title: '还没有光疗记录',
                message: '完成第一次治疗后这里会显示记录',
              ),
              builder: (records) => Column(
                children: [
                  for (final record in records)
                    _PhototherapyTile(record: record),
                ],
              ),
            ),
            SizedBox(height: SpacingTokens.x5),
            PhototherapyTrendSection(diseaseId: disease.id),
            SizedBox(height: SpacingTokens.x5),
            MeasurementTrendSection(diseaseId: disease.id),
            SizedBox(height: SpacingTokens.x5),
            PhotoTimelineSection(diseaseId: disease.id),
          ],
        ],
      ),
    );
  }

  Future<void> _addTask(
    BuildContext context,
    WidgetRef ref,
    Disease disease,
  ) async {
    final draft = await TaskFormSheet.show(
      context,
      diseaseId: disease.id,
      diseaseName: disease.name,
    );
    if (draft != null) {
      await saveTaskDraft(ref, draft);
    }
  }

  void _showPlanSheet(BuildContext context, WidgetRef ref, Disease disease) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CarePlanFormSheet(disease: disease),
    );
  }

  Future<void> _addPhototherapyRecord(
    BuildContext context,
    WidgetRef ref,
    Disease disease,
  ) async {
    await PhototherapyFormSheet.show(
      context,
      patientId: localPatientId,
      diseaseId: disease.id,
    );
  }
}

/// 指南模板卡：展示依据，点击按模板创建周期任务。
///
/// 同一患者同一模板只允许存在一份计划（防重复创建）：点击创建前先查询，
/// 已有计划（任意状态）时提示去「管理计划」区暂停 / 恢复 / 删除，不再重复创建。
class _TemplateCard extends ConsumerStatefulWidget {
  const _TemplateCard({required this.template, required this.disease});

  final DiseaseTaskTemplate template;
  final Disease disease;

  @override
  ConsumerState<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends ConsumerState<_TemplateCard> {
  /// 连点锁：创建请求在途时忽略后续点击（配合仓储查询防重）。
  bool _busy = false;

  DiseaseTaskTemplate get template => widget.template;
  Disease get disease => widget.disease;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final knowledge = KnowledgeBase.entries
        .where((e) => e.id == template.knowledgeId)
        .firstOrNull;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: SpacingTokens.x2),
      child: InkWell(
        borderRadius: RadiusTokens.mediumShape,
        onTap: _busy ? null : _create,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                  SizedBox(width: SpacingTokens.x2),
                  Expanded(
                    child: Text(template.title, style: context.bodyBoldStyle),
                  ),
                  Text(
                    template.defaultRecurrence.descriptionZh,
                    style: context.captionStyle.copyWith(color: scheme.primary),
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.x1),
              Text(template.description, style: context.secondaryLabelStyle),
              if (knowledge != null) ...[
                SizedBox(height: SpacingTokens.x2),
                Text(
                  '依据：${knowledge.title}（${knowledge.organization}）',
                  style: context.captionStyle,
                ),
              ],
              SizedBox(height: SpacingTokens.x2),
              Text(
                '按此模板创建 → 今天立即开始第一次治疗（出现在首页今日管理），'
                '之后按实际治疗日自动排程下一次',
                style: context.captionStyle.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    if (_busy) return;
    _busy = true;
    try {
      final repo = ref.read(repositoryProvider);
      // 防重：同患者同模板只允许一份计划（任意状态都占用）。
      final existing = await repo.getCarePlanByTemplate(
        localPatientId,
        template.id,
      );
      if (existing != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '「${template.title}」计划已存在，'
              '可在下方「管理计划」中暂停 / 恢复 / 删除，无需重复创建。',
            ),
          ),
        );
        return;
      }

      // 模板创建后立即开始：首次任务就是现在（今天出现在首页「今日管理」）。
      // 光疗链随后按实际完成时刻排程下一次（见 recurrence.nextPhototherapyOccurrence），
      // 因此从任何一天开始都保持每周 2～3 次、间隔 ≥2 天的模板节奏。
      final dueAt = DateTime.now();

      // 1. 模板实例化为管理计划（PlanDefinition → CarePlan）。
      final plan = template.buildCarePlan(
        patientId: localPatientId,
        diseaseId: disease.id,
        startAt: dueAt,
        endAtMonths: template.defaultEndAtMonths > 0
            ? template.defaultEndAtMonths
            : null,
      );
      await repo.saveCarePlan(plan);

      // 2. 计划生成首条任务（CarePlan → Task）。
      final task = template.buildFirstTask(
        patientId: localPatientId,
        diseaseId: disease.id,
        carePlanId: plan.id,
        dueAt: dueAt,
      );
      await repo.saveTask(task);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '已创建计划「${template.title}」，首次任务：'
            '${DateFormat('M月d日 HH:mm').format(dueAt)}',
          ),
        ),
      );
    } finally {
      _busy = false;
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前状态', style: context.labelBoldStyle),
            SizedBox(height: SpacingTokens.x2),
            Text(
              [
                disease.status.labelZh,
                if (disease.diagnosedAt != null)
                  '确诊于 ${DateFormat('yyyy/M/d').format(disease.diagnosedAt!)}',
              ].join(' · '),
              style: context.secondaryBodyStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Text(title, style: context.headlineStyle)),
        IconButton(
          icon: const Icon(Icons.add, size: 22),
          tooltip: '添加',
          color: scheme.primary,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _PlanTile extends ConsumerWidget {
  const _PlanTile({required this.plan});

  final CarePlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final template = DiseaseTemplates.all
        .where((t) => t.id == plan.templateId)
        .firstOrNull;

    final actions = switch (plan.status) {
      CarePlanStatus.active => [
        _PlanAction(label: '暂停', onPressed: () => _pause(context, ref)),
        _PlanAction(
          label: '完成计划',
          onPressed: () => _confirmComplete(context, ref),
        ),
        _PlanAction(
          label: '删除计划',
          onPressed: () => _delete(context, ref),
          destructive: true,
        ),
      ],
      CarePlanStatus.paused => [
        _PlanAction(label: '恢复计划', onPressed: () => _resume(context, ref)),
        _PlanAction(
          label: '删除计划',
          onPressed: () => _delete(context, ref),
          destructive: true,
        ),
      ],
      // 已完成 / 已取消：终态，仅可删除（删除后可重新按模板创建）。
      _ => [
        _PlanAction(
          label: '删除计划',
          onPressed: () => _delete(context, ref),
          destructive: true,
        ),
      ],
    };

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(plan.title, style: context.bodyBoldStyle)),
                Text(plan.status.labelZh, style: context.captionStyle),
              ],
            ),
            if (plan.description != null && plan.description!.isNotEmpty) ...[
              SizedBox(height: SpacingTokens.x1),
              Text(plan.description!, style: context.secondaryLabelStyle),
            ],
            if (template != null) ...[
              SizedBox(height: SpacingTokens.x1),
              Text(
                '周期：${template.defaultRecurrence.descriptionZh}'
                '${plan.endAt != null ? ' · 至 ${DateFormat('yyyy/M').format(plan.endAt!)}' : ''}',
                style: context.captionStyle.copyWith(color: scheme.primary),
              ),
            ],
            SizedBox(height: SpacingTokens.x2),
            Row(
              children: [
                for (final action in actions)
                  Expanded(
                    child: TextButton(
                      style: action.destructive
                          ? TextButton.styleFrom(foregroundColor: scheme.error)
                          : null,
                      onPressed: action.onPressed,
                      child: Text(action.label),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// 暂停：不再生成新任务并取消未完成任务的提醒（作用域 = 本计划，不影响其它计划）。
  Future<void> _pause(BuildContext context, WidgetRef ref) async {
    await ref.read(repositoryProvider).pauseCarePlan(plan.id);
    if (!context.mounted) return;
    _showSnack(context, '已暂停「${plan.title}」，未完成任务提醒已取消');
  }

  /// 恢复：重新排程并恢复未完成任务提醒；空链（暂停期间任务已全部完成）时
  /// 从当前时间重新锚点生成下一条任务，链重新开始。
  Future<void> _resume(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final now = DateTime.now();
    // 疗程已结束且链已空：提示删除重建，避免超出疗程继续生成。
    if (plan.endAt != null && now.isAfter(plan.endAt!)) {
      final pending = await repo.pendingTasksForPlan(plan.id);
      if (pending.isEmpty) {
        if (!context.mounted) return;
        _showSnack(
          context,
          '「${plan.title}」疗程已于 ${DateFormat('yyyy/M/d').format(plan.endAt!)} 结束；'
          '如需继续，可删除该计划后重新按模板创建。',
        );
        return;
      }
    }
    await repo.resumeCarePlan(plan.id);
    final pending = await repo.pendingTasksForPlan(plan.id);
    var restarted = false;
    if (pending.isEmpty && plan.templateId != null && plan.diseaseId != null) {
      final template = DiseaseTemplates.all
          .where((t) => t.id == plan.templateId)
          .firstOrNull;
      if (template != null) {
        final task = template.buildFirstTask(
          patientId: plan.patientId,
          diseaseId: plan.diseaseId!,
          carePlanId: plan.id,
          dueAt: now,
        );
        await repo.saveTask(task);
        restarted = true;
      }
    }
    if (!context.mounted) return;
    _showSnack(
      context,
      restarted ? '已恢复「${plan.title}」，从当前时间重新排程' : '已恢复「${plan.title}」',
    );
  }

  /// 完成计划（终态）：停止生成新任务并取消未完成任务提醒。
  Future<void> _confirmComplete(BuildContext context, WidgetRef ref) async {
    final ok = await showConfirmDialog(
      context,
      title: '完成计划',
      message:
          '将「${plan.title}」标记为已完成？完成后不再生成新任务，'
          '未完成任务与提醒会被清理。历史记录保留，可在删除后重新创建。',
      confirmLabel: '完成',
    );
    if (ok != true || !context.mounted) return;
    await ref.read(repositoryProvider).completeCarePlan(plan.id);
    if (!context.mounted) return;
    _showSnack(context, '已完成「${plan.title}」');
  }

  /// 删除计划：无数据直接删；有完成记录/执行补充时明确提示「历史保留」。
  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final overview = await repo.carePlanDeletionOverview(plan.id);
    if (!context.mounted) return;
    final pendingPart = overview.pendingCount == 0
        ? ''
        : '并移除 ${overview.pendingCount} 条未完成任务';
    final message = overview.hasHistory
        ? '「${plan.title}」已有完成记录（时间线 / 照片等）。'
              '删除计划不会删除这些历史记录，仅删除计划本身$pendingPart。'
              '删除后不可恢复，确定？'
        : '将删除计划「${plan.title}」$pendingPart。'
              '删除后不可恢复，确定？';
    final ok = await showConfirmDialog(
      context,
      title: '删除计划',
      message: message,
      confirmLabel: '删除',
    );
    if (ok != true || !context.mounted) return;
    await repo.deleteCarePlan(plan.id);
    if (!context.mounted) return;
    _showSnack(context, '已删除计划「${plan.title}」');
  }
}

/// 计划操作按钮描述。
class _PlanAction {
  const _PlanAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool destructive;
}

/// 光疗记录卡：日期、部位、剂量与皮肤反应摘要。
class _PhototherapyTile extends StatelessWidget {
  const _PhototherapyTile({required this.record});

  final PhototherapyRecord record;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final laterality = record.laterality == null
        ? null
        : BodyLaterality.values
              .where((v) => v.name == record.laterality)
              .firstOrNull;
    final bodyPart = [
      if (record.bodyPart != null && record.bodyPart!.isNotEmpty)
        record.bodyPart,
      if (laterality != null && laterality != BodyLaterality.none)
        laterality.labelZh,
    ].join(' · ');
    final noReaction = record.reactionSummary == '无不适';
    final reactionColor = record.blister
        ? colors.critical
        : (noReaction ? colors.success : colors.warning);

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.x2),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('M月d日 HH:mm').format(record.occurredAt),
              style: context.bodyBoldStyle,
            ),
            SizedBox(height: SpacingTokens.x1),
            Row(
              children: [
                Text(
                  '部位：${bodyPart.isEmpty ? '未记录' : bodyPart}',
                  style: context.secondaryLabelStyle,
                ),
                SizedBox(width: SpacingTokens.x2),
                Text(
                  '剂量：${record.doseLabel}',
                  style: context.secondaryLabelStyle,
                ),
              ],
            ),
            if (record.device != null && record.device!.isNotEmpty) ...[
              SizedBox(height: SpacingTokens.x1),
              Text('设备：${record.device}', style: context.captionStyle),
            ],
            SizedBox(height: SpacingTokens.x2),
            Row(
              children: [
                Icon(
                  noReaction ? Icons.check_circle_outline : Icons.warning_amber,
                  size: 16,
                  color: reactionColor,
                ),
                SizedBox(width: SpacingTokens.x1),
                Text(
                  record.reactionSummary,
                  style: context.labelStyle.copyWith(color: reactionColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: SpacingTokens.x2),
      child: InkWell(
        borderRadius: RadiusTokens.mediumShape,
        onTap: () => showTaskSheet(context, ref, task),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.x4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: context.bodyBoldStyle),
                    SizedBox(height: SpacingTokens.x1),
                    Row(
                      children: [
                        Text(
                          '${task.type.labelZh} · '
                          '${DateFormat('M/d HH:mm').format(task.dueAt)}',
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
              SizedBox(width: SpacingTokens.x2),
              InkWell(
                borderRadius: RadiusTokens.pillShape,
                onTap: () {
                  if (task.templateId == 'vitiligo.phototherapy') {
                    completePhototherapyTaskFlow(context, ref, task);
                  } else if (isDiabetesCheckTask(task)) {
                    completeDiabetesCheckTaskFlow(context, ref, task);
                  } else if (isGlucoseTask(task)) {
                    completeGlucoseTaskFlow(context, ref, task);
                  } else {
                    ref.read(completeTaskProvider.notifier).complete(task);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.x2),
                  child: Icon(
                    Icons.radio_button_unchecked,
                    color: scheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 管理计划创建表单（§6：CarePlan 是任务的上游来源）。
class _CarePlanFormSheet extends ConsumerStatefulWidget {
  const _CarePlanFormSheet({required this.disease});

  final Disease disease;

  @override
  ConsumerState<_CarePlanFormSheet> createState() => _CarePlanFormSheetState();
}

class _CarePlanFormSheetState extends ConsumerState<_CarePlanFormSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  SpacingTokens.x5,
                  SpacingTokens.x4,
                  SpacingTokens.x5,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('添加管理计划', style: context.headlineStyle),
                    SizedBox(height: SpacingTokens.x1),
                    Text(
                      '为「${widget.disease.name}」制定计划（如医生给出的治疗方案）',
                      style: context.secondaryLabelStyle,
                    ),
                    SizedBox(height: SpacingTokens.x4),
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: const InputDecoration(labelText: '计划名称'),
                    ),
                    SizedBox(height: SpacingTokens.x3),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: '计划说明（可选）'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                SpacingTokens.x5,
                SpacingTokens.x3,
                SpacingTokens.x5,
                SpacingTokens.x6,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('添加'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请填写计划名称')));
      return;
    }

    final repo = ref.read(repositoryProvider);
    await repo.saveCarePlan(
      CarePlan(
        id: newId(),
        patientId: localPatientId,
        diseaseId: widget.disease.id,
        title: title,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        status: CarePlanStatus.active,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }
}
