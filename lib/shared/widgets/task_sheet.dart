import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../domain/domain.dart';
import '../widgets/glass/glass.dart';

/// 任务操作弹层：查看任务、补写备注、撤销完成。
///
/// - 未完成：可补备注（保存到任务）；
/// - 已完成：可撤销（恢复待办，清理派生任务与时间线事件）。
Future<void> showTaskSheet(
  BuildContext context,
  WidgetRef ref,
  Task task,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TaskSheet(task: task),
  );
}

class _TaskSheet extends ConsumerStatefulWidget {
  const _TaskSheet({required this.task});

  final Task task;

  @override
  ConsumerState<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends ConsumerState<_TaskSheet> {
  late final TextEditingController _notesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.task.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final done = task.isDone;

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
              Row(
                children: [
                  Expanded(
                    child: Text(task.title, style: context.headlineStyle),
                  ),
                  _StatusBadge(
                    label: done ? '已完成' : '待完成',
                    color: done ? colors.success : colors.attention,
                  ),
                ],
              ),
              SizedBox(height: SpacingTokens.x2),
              Wrap(
                spacing: SpacingTokens.x2,
                runSpacing: SpacingTokens.x2,
                children: [
                  _MetaChip(
                    icon: Icons.tag,
                    label: task.type.labelZh,
                  ),
                  _MetaChip(
                    icon: Icons.schedule,
                    label: DateFormat('M月d日 HH:mm').format(task.dueAt),
                  ),
                  _MetaChip(
                    icon: Icons.rule_outlined,
                    label: task.source.labelZh,
                  ),
                  if (task.isRecurring)
                    _MetaChip(
                      icon: Icons.repeat,
                      label: task.recurrence.descriptionZh,
                    ),
                ],
              ),
              if (task.description != null &&
                  task.description!.isNotEmpty) ...[
                SizedBox(height: SpacingTokens.x3),
                Text(task.description!, style: context.secondaryBodyStyle),
              ],
              if (done && task.completedAt != null) ...[
                SizedBox(height: SpacingTokens.x2),
                Text(
                  '完成于 ${DateFormat('M月d日 HH:mm').format(task.completedAt!)}',
                  style: context.captionStyle.copyWith(color: colors.success),
                ),
              ],
              SizedBox(height: SpacingTokens.x4),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '备注（执行情况，如剂量、感受）',
                ),
              ),
              SizedBox(height: SpacingTokens.x3),
              GlassButton(
                expanded: true,
                type: GlassButtonType.glass,
                onPressed: _saving ? null : _saveNotes,
                child: const Text('保存备注'),
              ),
              if (done) ...[
                SizedBox(height: SpacingTokens.x2),
                GlassButton(
                  expanded: true,
                  type: GlassButtonType.plain,
                  onPressed: _saving ? null : _revert,
                  child: Text(
                    '撤销完成',
                    style: TextStyle(color: colors.warning),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveNotes() async {
    final text = _notesController.text.trim();
    setState(() => _saving = true);
    await ref
        .read(repositoryProvider)
        .updateTaskNotes(widget.task.id, text.isEmpty ? null : text);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('备注已保存')),
      );
    }
  }

  Future<void> _revert() async {
    final confirmed = await showGlassConfirm(
      context,
      title: '撤销完成',
      message: '将「${widget.task.title}」恢复为待完成，'
          '并删除本次完成记录及自动生成的下一次任务。确定？',
      confirmLabel: '撤销',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    await ref.read(revertTaskProvider.notifier).revert(widget.task);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已撤销，任务恢复待完成')),
      );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SpacingTokens.x3,
        vertical: SpacingTokens.x1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: RadiusTokens.pillShape,
      ),
      child: Text(
        label,
        style: context.captionStyle.copyWith(color: color),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.textTertiary),
        SizedBox(width: SpacingTokens.x1),
        Text(label, style: context.captionStyle),
      ],
    );
  }
}

/// 玻璃确认对话框。
Future<bool?> showGlassConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '确定',
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => GlassSurface(
      level: GlassLevel.overlay,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.xlarge),
      ),
      padding: EdgeInsets.all(SpacingTokens.x5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.headlineStyle),
          SizedBox(height: SpacingTokens.x3),
          Text(message, style: context.secondaryBodyStyle),
          SizedBox(height: SpacingTokens.x4),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  type: GlassButtonType.glass,
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('取消'),
                ),
              ),
              SizedBox(width: SpacingTokens.x3),
              Expanded(
                child: GlassButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
