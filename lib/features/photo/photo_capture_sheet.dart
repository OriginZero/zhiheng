import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';

/// 医疗照片拍摄弹层（开发文档 §34）。
///
/// 拍摄前按引导 checklist 确认拍摄条件，拍照后把图片复制到应用文档
/// 目录 photos/，返回构造好的 [CarePhoto]（不入库，由调用方保存）。
///
/// 患处照片走默认文案与 [kPhotoGuideItems]；检查报告 / 化验单等单据照片
/// 由调用方传 [PhotoKind.document] 与 [kPhotoDocumentGuideItems]。
///
/// 用法：
/// ```dart
/// final photo = await PhotoCaptureSheet.show(
///   context,
///   patientId: patientId,
///   diseaseId: diseaseId,
/// );
/// ```
class PhotoCaptureSheet extends StatefulWidget {
  const PhotoCaptureSheet({
    super.key,
    required this.patientId,
    required this.diseaseId,
    this.kind = PhotoKind.after,
    this.phototherapyRecordId,
    this.title = '拍下患处照片',
    this.guideHint = '为便于长期对比，请尽量保持与上次一致的拍摄条件。',
    this.guideItems = kPhotoGuideItems,
  });

  final String patientId;
  final String diseaseId;

  /// 拍摄时机（默认治疗后；单据照片传 [PhotoKind.document]）。
  final PhotoKind kind;

  /// 关联的光疗记录（可选）。
  final String? phototherapyRecordId;

  /// 弹层标题（检查报告/化验单等单据照片可替换默认文案）。
  final String title;

  /// 拍摄引导说明文案（单据照片用单据视角的提示）。
  final String guideHint;

  /// 拍摄引导 checklist（单据照片用 [kPhotoDocumentGuideItems]）。
  final List<PhotoGuideItem> guideItems;

  /// 统一的弹层入口。取消 / 关闭返回 null。
  static Future<CarePhoto?> show(
    BuildContext context, {
    required String patientId,
    required String diseaseId,
    PhotoKind kind = PhotoKind.after,
    String? phototherapyRecordId,
    String title = '拍下患处照片',
    String guideHint = '为便于长期对比，请尽量保持与上次一致的拍摄条件。',
    List<PhotoGuideItem> guideItems = kPhotoGuideItems,
  }) {
    // 官方 M3 bottom sheet：表面色 / 顶圆角 / 遮罩由主题 bottomSheetTheme 提供。
    return showModalBottomSheet<CarePhoto>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PhotoCaptureSheet(
        patientId: patientId,
        diseaseId: diseaseId,
        kind: kind,
        phototherapyRecordId: phototherapyRecordId,
        title: title,
        guideHint: guideHint,
        guideItems: guideItems,
      ),
    );
  }

  @override
  State<PhotoCaptureSheet> createState() => _PhotoCaptureSheetState();
}

class _PhotoCaptureSheetState extends State<PhotoCaptureSheet> {
  /// 默认全勾选（可直接保存），用户可取消不符合的项。
  late final Set<String> _checked;
  bool _busy = false;

  bool get _allChecked => _checked.length == widget.guideItems.length;

  @override
  void initState() {
    super.initState();
    _checked = {for (final item in widget.guideItems) item.key};
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.x5,
        SpacingTokens.x4,
        SpacingTokens.x5,
        SpacingTokens.x8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: context.headlineStyle),
            SizedBox(height: SpacingTokens.x1),
            Text(
              '本次拍摄：${widget.kind.labelZh}',
              style: context.secondaryLabelStyle,
            ),
            SizedBox(height: SpacingTokens.x4),
            Text('拍摄引导', style: context.labelBoldStyle),
            SizedBox(height: SpacingTokens.x1),
            Text(widget.guideHint, style: context.secondaryLabelStyle),
            SizedBox(height: SpacingTokens.x1),
            for (final item in widget.guideItems)
              Row(
                children: [
                  Checkbox(
                    value: _checked.contains(item.key),
                    onChanged: _busy
                        ? null
                        : (v) => setState(() {
                            if (v ?? false) {
                              _checked.add(item.key);
                            } else {
                              _checked.remove(item.key);
                            }
                          }),
                  ),
                  Expanded(child: Text(item.labelZh, style: context.bodyStyle)),
                ],
              ),
            SizedBox(height: SpacingTokens.x4),
            FilledButton.icon(
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: _allChecked && !_busy
                  ? () => _capture(ImageSource.camera)
                  : null,
              label: Text(_busy ? '保存中…' : '拍照'),
            ),
            SizedBox(height: SpacingTokens.x2),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.photo_library_outlined),
              onPressed: _allChecked && !_busy
                  ? () => _capture(ImageSource.gallery)
                  : null,
              label: const Text('从相册选择'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capture(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null) return; // 用户取消，保持弹层打开。
    setState(() => _busy = true);
    try {
      final photo = await _buildPhoto(picked);
      if (!mounted) return;
      Navigator.of(context).pop(photo);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 把拍摄结果复制到应用文档目录 photos/，并构造 [CarePhoto]。
  Future<CarePhoto> _buildPhoto(XFile picked) async {
    final id = newId();
    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(docsDir.path, 'photos'));
    await photosDir.create(recursive: true);
    final targetPath = p.join(photosDir.path, 'photo_$id.jpg');
    await File(picked.path).copy(targetPath);
    return CarePhoto(
      id: id,
      patientId: widget.patientId,
      diseaseId: widget.diseaseId,
      phototherapyRecordId: widget.phototherapyRecordId,
      kind: widget.kind,
      filePath: targetPath,
      takenAt: DateTime.now(),
      guidePassed: [
        for (final item in widget.guideItems)
          if (_checked.contains(item.key)) item.key,
      ],
    );
  }
}
