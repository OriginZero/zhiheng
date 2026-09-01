import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../widgets/glass/glass.dart';

/// 任务创建结果。
class TaskDraft {
  const TaskDraft({
    required this.title,
    required this.type,
    required this.priority,
    required this.dueAt,
    this.diseaseId,
    this.description,
  });

  final String title;
  final TaskType type;
  final TaskPriority priority;
  final DateTime dueAt;
  final String? diseaseId;
  final String? description;
}

/// 任务创建表单（玻璃弹层，§11 链路中的 UserCreated 任务入口）。
///
/// 用法：`TaskFormSheet.show(context)` → 返回 [TaskDraft]（取消返回 null）。
class TaskFormSheet extends ConsumerStatefulWidget {
  const TaskFormSheet({
    super.key,
    this.diseaseId,
    this.diseaseName,
  });

  /// 预绑定的疾病（从疾病详情页发起时）。
  final String? diseaseId;
  final String? diseaseName;

  static Future<TaskDraft?> show(
    BuildContext context, {
    String? diseaseId,
    String? diseaseName,
  }) {
    return showModalBottomSheet<TaskDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) => TaskFormSheet(
        diseaseId: diseaseId,
        diseaseName: diseaseName,
      ),
    );
  }

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _titleController = TextEditingController();
  TaskType _type = TaskType.custom;
  TaskPriority _priority = TaskPriority.required;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dueDate = DateTime(now.year, now.month, now.day);
    _dueTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
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
              Text('添加任务', style: context.headlineStyle),
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: '任务名称'),
              ),
              SizedBox(height: SpacingTokens.x4),
              Text('类型', style: context.labelBoldStyle),
              SizedBox(height: SpacingTokens.x2),
              Wrap(
                spacing: SpacingTokens.x2,
                runSpacing: SpacingTokens.x2,
                children: [
                  for (final type in TaskType.values)
                    _ChoiceChip(
                      label: type.labelZh,
                      selected: _type == type,
                      onTap: () => setState(() => _type = type),
                    ),
                ],
              ),
              SizedBox(height: SpacingTokens.x4),
              Text('优先级', style: context.labelBoldStyle),
              SizedBox(height: SpacingTokens.x2),
              Wrap(
                spacing: SpacingTokens.x2,
                children: [
                  for (final p in TaskPriority.values)
                    _ChoiceChip(
                      label: p.labelZh,
                      selected: _priority == p,
                      onTap: () => setState(() => _priority = p),
                    ),
                ],
              ),
              SizedBox(height: SpacingTokens.x4),
              Row(
                children: [
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.calendar_today_outlined,
                      label: DateFormat('yyyy/M/d').format(_dueDate),
                      onTap: _pickDate,
                    ),
                  ),
                  SizedBox(width: SpacingTokens.x3),
                  Expanded(
                    child: _FieldButton(
                      icon: Icons.access_time,
                      label: DateFormat('HH:mm').format(
                        DateTime(2000, 1, 1, _dueTime.hour, _dueTime.minute),
                      ),
                      onTap: _pickTime,
                    ),
                  ),
                ],
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _dueTime);
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写任务名称')),
      );
      return;
    }
    Navigator.of(context).pop(
      TaskDraft(
        title: title,
        type: _type,
        priority: _priority,
        dueAt: DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          _dueTime.hour,
          _dueTime.minute,
        ),
        diseaseId: widget.diseaseId,
      ),
    );
  }
}

/// 把草稿保存为任务（来源固定为 userCreated，§10 来源可追踪）。
Future<void> saveTaskDraft(WidgetRef ref, TaskDraft draft) async {
  final repo = ref.read(repositoryProvider);
  final task = Task(
    id: newId(),
    patientId: localPatientId,
    diseaseId: draft.diseaseId,
    title: draft.title,
    description: draft.description,
    type: draft.type,
    source: TaskSource.userCreated,
    priority: draft.priority,
    dueAt: draft.dueAt,
  );
  await repo.saveTask(task);
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return InkWell(
      borderRadius: RadiusTokens.pillShape,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x3,
          vertical: SpacingTokens.x2,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.brand : colors.divider,
          borderRadius: RadiusTokens.pillShape,
        ),
        child: Text(
          label,
          style: context.labelStyle.copyWith(
            color: selected ? colors.onBrand : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return InkWell(
      borderRadius: RadiusTokens.mediumShape,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x4,
          vertical: SpacingTokens.x3,
        ),
        decoration: BoxDecoration(
          color: colors.divider.withValues(alpha: 0.5),
          borderRadius: RadiusTokens.mediumShape,
          border: Border.all(color: colors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.textSecondary),
            SizedBox(width: SpacingTokens.x2),
            Expanded(
              child: Text(label, style: context.labelStyle),
            ),
          ],
        ),
      ),
    );
  }
}
