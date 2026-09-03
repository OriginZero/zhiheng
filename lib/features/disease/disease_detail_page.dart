import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../features/task/disease_templates.dart';
import '../phototherapy/phototherapy_task_flow.dart';
import '../diabetes/glucose_task_flow.dart';

import '../../shared/domain/domain.dart';
import '../../shared/forms/task_form_sheet.dart';
import '../../shared/widgets/task_sheet.dart';
import 'phototherapy_trend_section.dart';
import '../photo/photo_timeline_section.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/glass/glass.dart';
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
        backgroundColor: Colors.transparent,
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
      backgroundColor: Colors.transparent,
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
            GlassCard(
              child: Text(
                '还没有管理计划。为这个疾病制定计划后，可以据此生成每日任务。',
                style: context.secondaryLabelStyle,
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
              action: GlassButton(
                type: GlassButtonType.glass,
                icon: Icons.add,
                onPressed: () => _addTask(context, ref, disease),
                child: const Text('添加任务'),
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
      backgroundColor: Colors.transparent,
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
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({required this.template, required this.disease});

  final DiseaseTaskTemplate template;
  final Disease disease;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final knowledge = KnowledgeBase.entries
        .where((e) => e.id == template.knowledgeId)
        .firstOrNull;

    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      onTap: () => _create(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18, color: colors.brand),
              SizedBox(width: SpacingTokens.x2),
              Expanded(
                child: Text(template.title, style: context.bodyBoldStyle),
              ),
              Text(
                template.defaultRecurrence.descriptionZh,
                style: context.captionStyle.copyWith(color: colors.brand),
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
            style: context.captionStyle.copyWith(color: colors.brand),
          ),
        ],
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final now = DateTime.now();

    // 模板创建后立即开始：首次任务就是现在（今天出现在首页「今日管理」）。
    // 光疗链随后按实际完成时刻排程下一次（见 recurrence.nextPhototherapyOccurrence），
    // 因此从任何一天开始都保持每周 2～3 次、间隔 ≥2 天的模板节奏。
    final dueAt = now;

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

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '已创建计划「${template.title}」，首次任务：'
            '${DateFormat('M月d日 HH:mm').format(dueAt)}',
          ),
        ),
      );
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.disease});

  final Disease disease;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onAdd});

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return Row(
      children: [
        Expanded(child: Text(title, style: context.headlineStyle)),
        IconButton(
          icon: const Icon(Icons.add, size: 22),
          tooltip: '添加',
          color: colors.brand,
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
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final template = DiseaseTemplates.all
        .where((t) => t.id == plan.templateId)
        .firstOrNull;
    final active = plan.status == CarePlanStatus.active;

    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
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
              style: context.captionStyle.copyWith(color: colors.brand),
            ),
          ],
          if (active) ...[
            SizedBox(height: SpacingTokens.x2),
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    type: GlassButtonType.plain,
                    onPressed: () => ref
                        .read(repositoryProvider)
                        .updateCarePlanStatus(plan.id, CarePlanStatus.paused),
                    child: const Text('暂停'),
                  ),
                ),
                Expanded(
                  child: GlassButton(
                    type: GlassButtonType.plain,
                    onPressed: () => ref
                        .read(repositoryProvider)
                        .updateCarePlanStatus(
                          plan.id,
                          CarePlanStatus.completed,
                        ),
                    child: const Text('完成计划'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
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

    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
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
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return GlassCard(
      margin: EdgeInsets.only(bottom: SpacingTokens.x2),
      onTap: () => showTaskSheet(context, ref, task),
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
                      Icon(Icons.repeat, size: 12, color: colors.brand),
                      Text(
                        task.recurrence.descriptionZh,
                        style: context.captionStyle.copyWith(
                          color: colors.brand,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: RadiusTokens.pillShape,
            onTap: () {
              if (task.templateId == 'vitiligo.phototherapy') {
                completePhototherapyTaskFlow(context, ref, task);
              } else if (isGlucoseTask(task)) {
                completeGlucoseTaskFlow(context, ref, task);
              } else {
                ref.read(completeTaskProvider.notifier).complete(task);
              }
            },
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassSurface(
        level: GlassLevel.overlay,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.xlarge),
        ),
        padding: EdgeInsets.fromLTRB(
          SpacingTokens.x5,
          SpacingTokens.x4,
          SpacingTokens.x5,
          SpacingTokens.x6,
        ),
        child: SingleChildScrollView(
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
              SizedBox(height: SpacingTokens.x4),
              GlassButton(
                expanded: true,
                onPressed: _submit,
                child: const Text('添加'),
              ),
            ],
          ),
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
