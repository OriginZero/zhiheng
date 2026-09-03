import 'package:flutter/material.dart';

import '../../core/theme/tokens/radius_tokens.dart';
import '../../core/theme/tokens/spacing_tokens.dart';
import '../../core/theme/tokens/typography_tokens.dart';
import '../domain/domain.dart';
import 'glass/glass_button.dart';
import 'glass/glass_surface.dart';

/// 任务完成补充记录的通用返回结果。
///
/// 可为空补充：用户选择「仅完成」时 [supplement] 为 null，任务仍可完成。
class RecordCompletionResult {
  const RecordCompletionResult({this.supplement, this.notes});

  final TaskSupplement? supplement;
  final String? notes;
}

/// 打开「任务完成补充记录」弹层（通用外壳的唯一入口）。
///
/// 业务弹层不再自行 `showModalBottomSheet`：透明背景、遮罩、键盘避让
/// （viewInsets）都在这里统一处理。
Future<RecordCompletionResult?> showRecordCompletionSheet(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<RecordCompletionResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
      ),
      child: builder(sheetContext),
    ),
  );
}

/// 任务完成补充记录弹层通用外壳（开发文档 §10、§11）。
///
/// 外壳统一承载：玻璃容器、标题与说明、备注输入、主按钮「保存并完成」
/// 与次要按钮「仅完成，不记录本次细节」、底部提示、busy 状态与结果返回。
/// 各任务类型（光疗部位/血糖读数/未来的新模块）只需把中间字段区作为
/// [child] 传入，并实现 [onSubmit]——字段内容不同，外壳一致。
///
/// [onSubmit] 返回 null 表示校验未通过（自行弹提示），弹层保持打开；
/// 返回 [RecordCompletionResult] 时以该结果关闭弹层。
class RecordCompletionSheet extends StatefulWidget {
  const RecordCompletionSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onSubmit,
    this.description,
    this.notesLabel = '本次备注（可选）',
    this.saveLabelSuffix,
  });

  final String title;

  /// 标题下的次要说明（如医学安全口径的「这里只做记录」）。
  final String? description;

  /// 中间字段区（滚动内容的一部分），由调用方按任务类型构建。
  final Widget child;

  /// 备注输入框标签。
  final String notesLabel;

  /// 主按钮文案后缀（如低血糖时「（低血糖）」）；null 时主按钮为「保存并完成」。
  final String? saveLabelSuffix;

  final Future<RecordCompletionResult?> Function({
    required bool skip,
    required String notes,
  })
  onSubmit;

  @override
  State<RecordCompletionSheet> createState() => _RecordCompletionSheetState();
}

class _RecordCompletionSheetState extends State<RecordCompletionSheet> {
  final _notesController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool skip}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await widget.onSubmit(
      skip: skip,
      notes: _notesController.text.trim(),
    );
    if (!mounted) return;
    if (result == null) {
      // 校验未通过：调用方已提示，留在弹层继续填写。
      setState(() => _busy = false);
      return;
    }
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final suffix = widget.saveLabelSuffix;

    return GlassSurface(
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
            Text(widget.title, style: context.headlineStyle),
            if (widget.description != null) ...[
              SizedBox(height: SpacingTokens.x1),
              Text(widget.description!, style: context.secondaryLabelStyle),
            ],
            SizedBox(height: SpacingTokens.x4),
            widget.child,
            SizedBox(height: SpacingTokens.x3),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(labelText: widget.notesLabel),
            ),
            SizedBox(height: SpacingTokens.x4),
            GlassButton(
              expanded: true,
              icon: Icons.check_circle_outline,
              onPressed: _busy ? null : () => _submit(skip: false),
              child: Text(suffix == null ? '保存并完成' : '保存并完成$suffix'),
            ),
            SizedBox(height: SpacingTokens.x2),
            TextButton(
              onPressed: _busy ? null : () => _submit(skip: true),
              child: const Text('仅完成，不记录本次细节'),
            ),
            SizedBox(height: SpacingTokens.x1),
            Text(
              '也可以稍后在任务详情里补写备注。',
              style: context.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
