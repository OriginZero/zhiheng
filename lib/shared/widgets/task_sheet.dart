import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../domain/domain.dart';
import '../widgets/photo_thumb.dart';

/// 任务操作弹层：查看任务详情、查看/删除执行补充、撤销完成。
///
/// - 点击任务条 = 查看详情（不提供备注编辑，历史备注仅在时间线展示）；
/// - 有执行补充：查看部位/时长/照片，可主动删除（含关联照片）；
/// - 已完成：可撤销（恢复待办，清理派生任务与时间线事件；
///   历史备注与执行补充保留，只有主动删除才丢弃）。
Future<void> showTaskSheet(BuildContext context, WidgetRef ref, Task task) {
  // 官方 M3 bottom sheet：表面色 / 顶圆角 / 遮罩由主题 bottomSheetTheme 提供。
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
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
  bool _saving = false;

  /// 该任务的补充照片（v8：勾选光疗任务时按部位上传）。
  List<CarePhoto> _photos = const [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (widget.task.supplement == null) return;
    final photos = await ref
        .read(repositoryProvider)
        .photosForTask(widget.task.id);
    if (mounted) {
      setState(() => _photos = photos);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final done = task.isDone;

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
                        _MetaChip(icon: Icons.tag, label: task.type.labelZh),
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
                      Text(
                        task.description!,
                        style: context.secondaryBodyStyle,
                      ),
                    ],
                    if (done && task.completedAt != null) ...[
                      SizedBox(height: SpacingTokens.x2),
                      Text(
                        '完成于 ${DateFormat('M月d日 HH:mm').format(task.completedAt!)}',
                        style: context.captionStyle.copyWith(
                          color: colors.success,
                        ),
                      ),
                    ],
                    if (task.supplement != null) ...[
                      SizedBox(height: SpacingTokens.x4),
                      _buildSupplementSection(task),
                    ],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (done) ...[
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _saving ? null : _revert,
                        style: TextButton.styleFrom(
                          foregroundColor: colors.warning,
                        ),
                        child: const Text('撤销完成'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 补充记录展示：schema 标题 + 结构化内容行 + 照片缩略 + 主动删除入口。
  Widget _buildSupplementSection(Task task) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final supplement = task.supplement;
    final parts = phototherapyExposureParts(supplement);
    final isPhototherapy = supplement?.schema == kPhototherapyExposureSchema;
    final isDiabetesCheck = supplement?.schema == kDiabetesCheckReportSchema;
    final checkPhotoIds = diabetesCheckReportPhotoIds(supplement);
    final title = isPhototherapy
        ? '本次治疗补充'
        : isDiabetesCheck
        ? '本次检查记录'
        : '本次执行记录';
    final icon = isPhototherapy
        ? Icons.healing_outlined
        : isDiabetesCheck
        ? Icons.description_outlined
        : Icons.assignment_outlined;
    return Container(
      padding: EdgeInsets.all(SpacingTokens.x3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: RadiusTokens.largeShape,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: scheme.primary),
              SizedBox(width: SpacingTokens.x2),
              Expanded(child: Text(title, style: context.labelBoldStyle)),
              InkWell(
                borderRadius: RadiusTokens.pillShape,
                onTap: _saving ? null : _deleteSupplement,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacingTokens.x2,
                    vertical: SpacingTokens.x1,
                  ),
                  child: Text(
                    '删除记录',
                    style: context.captionStyle.copyWith(color: colors.warning),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SpacingTokens.x2),
          if (parts.isNotEmpty)
            for (final part in parts) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(part.name, style: context.bodyStyle)),
                  Text(
                    formatDurationZh(part.durationSeconds) ?? '时长未记录',
                    style: context.secondaryLabelStyle,
                  ),
                  if (part.photoIds.isNotEmpty) ...[
                    SizedBox(width: SpacingTokens.x2),
                    Text(
                      '${part.photoIds.length} 张照片',
                      style: context.captionStyle,
                    ),
                  ],
                ],
              ),
              SizedBox(height: SpacingTokens.x1),
            ]
          else if (isDiabetesCheck)
            Text(
              checkPhotoIds == null || checkPhotoIds.isEmpty
                  ? '已记录本次检查结果。'
                  : '已上传 ${checkPhotoIds.length} 张检查单据照片。',
              style: context.secondaryLabelStyle,
            )
          else
            Text('已记录执行补充。', style: context.secondaryLabelStyle),
          if (_photos.isNotEmpty) ...[
            SizedBox(height: SpacingTokens.x2),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, _) => SizedBox(width: SpacingTokens.x2),
                itemBuilder: (context, index) =>
                    PhotoThumb(photo: _photos[index], size: 96),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 主动删除本次治疗补充（含关联照片）。
  /// 撤销完成不清空补充，只有这里（或重新记录覆盖）才会丢弃。
  Future<void> _deleteSupplement() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '删除本次治疗记录',
      message:
          '将删除「${widget.task.title}」上记录的执行补充'
          '（部位时长 / 检查单据照片等）。删除后不可恢复，确定？',
      confirmLabel: '删除',
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    await ref.read(repositoryProvider).deleteTaskSupplement(widget.task.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('已删除本次治疗记录')));
  }

  Future<void> _revert() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '撤销完成',
      message:
          '将「${widget.task.title}」恢复为待完成，'
          '并删除本次完成沉淀的时间线记录与自动生成的下一次任务。\n\n'
          '已填写的备注与本次治疗补充（含照片）会保留，可在确认无误后手动删除。确定？',
      confirmLabel: '撤销',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    await ref.read(revertTaskProvider.notifier).revert(widget.task);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已撤销，任务恢复待完成')));
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
      child: Text(label, style: context.captionStyle.copyWith(color: color)),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.outline),
        SizedBox(width: SpacingTokens.x1),
        Text(label, style: context.captionStyle),
      ],
    );
  }
}

/// M3 确认对话框（函数名保持兼容，由旧 bottom sheet 实现改为官方 AlertDialog）。
///
/// 标题 / 内容 / 按钮的样式与表面由主题 dialogTheme 统一提供。
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '确定',
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
