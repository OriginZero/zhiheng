import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/forms/task_form_sheet.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/glass/glass.dart';

/// 疾病详情页：当前计划、未完成任务、添加任务入口。
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(disease.name)),
      body: ListView(
        padding: EdgeInsets.all(SpacingTokens.x5),
        children: [
          _StatusCard(disease: disease),
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
              children: [
                for (final task in list) _TaskTile(task: task),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask(
      BuildContext context, WidgetRef ref, Disease disease) async {
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

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan});

  final CarePlan plan;

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: context.bodyBoldStyle),
                SizedBox(height: SpacingTokens.x1),
                Text(
                  '${task.type.labelZh} · ${DateFormat('M/d HH:mm').format(task.dueAt)}',
                  style: context.captionStyle,
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: RadiusTokens.pillShape,
            onTap: () => ref.read(completeTaskProvider.notifier).complete(task),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写计划名称')),
      );
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
