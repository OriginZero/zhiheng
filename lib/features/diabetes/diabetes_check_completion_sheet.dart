import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/core_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/photo_thumb.dart';
import '../../shared/widgets/record_completion_sheet.dart';
import '../photo/photo_capture_sheet.dart';

/// 糖尿病检查类任务（复查 HbA1c / 年度糖尿病综合检查）勾选完成时的
/// 「记录检查结果」表单。
///
/// 检查类任务的核心产出是本次检查的报告 / 化验单：表单提供多张单据照片
/// 上传（拍照 / 相册，走 [PhotoCaptureSheet] 单据引导），照片关联任务入库
/// （care_photos.taskId），补充以 [kDiabetesCheckReportSchema] 保存。
/// 照片不强制：没有单据也能直接完成任务（仅记录备注）。
///
/// 表单只做记录与文件留存，不做任何医学解读（§4：医学结论以医生为准）。
///
/// 返回：保存 → [RecordCompletionResult]；用户取消（下滑/返回）→ null，
/// 任务保持待办状态，不产生任何写入。
class DiabetesCheckCompletionSheet extends ConsumerStatefulWidget {
  const DiabetesCheckCompletionSheet({super.key, required this.task});

  /// 被勾选的检查类任务（templateId = diabetes.hba1c / diabetes.annual）。
  final Task task;

  static Future<RecordCompletionResult?> show(
    BuildContext context, {
    required Task task,
  }) {
    return showRecordCompletionSheet(
      context,
      builder: (_) => DiabetesCheckCompletionSheet(task: task),
    );
  }

  @override
  ConsumerState<DiabetesCheckCompletionSheet> createState() =>
      _DiabetesCheckCompletionSheetState();
}

class _DiabetesCheckCompletionSheetState
    extends ConsumerState<DiabetesCheckCompletionSheet> {
  /// 单据照片草稿（未入库；保存时关联任务，取消/仅完成时删除文件）。
  final List<CarePhoto> _photos = [];

  /// 按任务模板给弹层标题与说明（HbA1c 复查 / 年度综合检查）。
  String get _title => widget.task.templateId == 'diabetes.annual'
      ? '记录年度检查结果'
      : '记录 HbA1c 复查结果';

  String get _description => widget.task.templateId == 'diabetes.annual'
      ? '完成年度综合评估后，上传本次检查报告单据照片'
            '（血压 / 血脂 / 肾功能 / 眼底 / 足部等），'
            '便于医生复诊与长期对比。这里只做记录留存。'
      : '复查后上传本次化验单照片（如 HbA1c 报告），'
            '便于医生复诊与对比变化。这里只做记录留存。';

  Future<void> _addPhoto() async {
    final photo = await PhotoCaptureSheet.show(
      context,
      patientId: widget.task.patientId,
      diseaseId: widget.task.diseaseId!,
      kind: PhotoKind.document,
      title: '拍下检查单据',
      guideHint: '单据应完整、清晰入镜（化验单、检查报告等），便于医生复诊时查看。',
      guideItems: kPhotoDocumentGuideItems,
    );
    if (photo == null || !mounted) return;
    setState(() => _photos.add(photo));
  }

  /// 移除草稿照片并删除文件（未入库，避免孤儿文件）。
  Future<void> _removePhoto(int index) async {
    final photo = _photos[index];
    setState(() => _photos.removeAt(index));
    try {
      final file = File(photo.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // 清理失败不阻塞交互。
    }
  }

  Future<void> _discardDraftFiles() async {
    for (final photo in _photos) {
      try {
        final file = File(photo.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // 清理失败不阻塞完成流程。
      }
    }
  }

  Future<RecordCompletionResult?> _submit({
    required bool skip,
    required String notes,
  }) async {
    // 收起输入法再提交，避免键盘遮挡提示。
    FocusScope.of(context).unfocus();
    final notesValue = notes.isEmpty ? null : notes;

    // 「仅完成」或没有上传单据 → 已拍草稿不留（无引用即孤儿），任务照常完成。
    if (skip || _photos.isEmpty) {
      await _discardDraftFiles();
      return RecordCompletionResult(supplement: null, notes: notesValue);
    }

    // 有单据照片：关联任务入库，补充记录 photoIds。
    final repo = ref.read(repositoryProvider);
    final photoIds = <String>[];
    for (final photo in _photos) {
      await repo.addCarePhoto(photo.copyWith(taskId: widget.task.id));
      photoIds.add(photo.id);
    }
    return RecordCompletionResult(
      supplement: TaskSupplement(
        schema: kDiabetesCheckReportSchema,
        content: <String, Object?>{'photoIds': photoIds},
      ),
      notes: notesValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RecordCompletionSheet(
      title: _title,
      description: _description,
      notesLabel: '本次备注（可选，如复查建议）',
      onSubmit: _submit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('检查报告 / 化验单照片', style: context.labelBoldStyle),
          SizedBox(height: SpacingTokens.x1),
          Text(
            '可上传多张（化验单、检查报告等）。点击缩略图可全屏查看。',
            style: context.secondaryLabelStyle,
          ),
          SizedBox(height: SpacingTokens.x2),
          if (_photos.isEmpty)
            Text('还没有上传单据，可点击下方按钮拍摄或从相册选择。', style: context.secondaryLabelStyle)
          else ...[
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, _) => SizedBox(width: SpacingTokens.x2),
                itemBuilder: (context, index) => PhotoThumb(
                  photo: _photos[index],
                  size: 96,
                  removeTooltip: '删除该单据照片',
                  onRemove: () => _removePhoto(index),
                ),
              ),
            ),
            SizedBox(height: SpacingTokens.x2),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: _addPhoto,
              label: const Text('拍摄 / 选择单据照片'),
            ),
          ),
        ],
      ),
    );
  }
}
