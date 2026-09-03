import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../core/storage/local_repository.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/glass/glass.dart';
import '../../shared/widgets/photo_viewer_page.dart';
import '../../shared/widgets/record_completion_sheet.dart';
import '../../shared/widgets/task_sheet.dart';
import '../photo/photo_capture_sheet.dart';

/// 308nm 光疗任务勾选完成时填写的「本次治疗补充」表单（开发文档 §10）。
///
/// 家庭 308nm 设备通常按时间剂量操作，且一次治疗可能覆盖多个部位：
/// 每个部位可记录照射时长（分/秒，如「1 分半」= 1 分 30 秒）并上传该部位照片。
/// 数据以 [TaskSupplement]（schema 可扩展）保存，不属于光疗记录的强结构。
///
/// 表单只做记录，不给出剂量/时长建议（§4：以医生方案与设备说明书为准）。
///
/// 返回：保存 → [RecordCompletionResult]；用户取消（下滑/返回）→ null，
/// 任务保持待办状态，不产生任何写入。
class PhototherapyCompletionSheet extends ConsumerStatefulWidget {
  const PhototherapyCompletionSheet({super.key, required this.task});

  /// 被勾选的 308nm 光疗任务（templateId = vitiligo.phototherapy）。
  final Task task;

  static Future<RecordCompletionResult?> show(
    BuildContext context, {
    required Task task,
  }) {
    return showRecordCompletionSheet(
      context,
      builder: (_) => PhototherapyCompletionSheet(task: task),
    );
  }

  @override
  ConsumerState<PhototherapyCompletionSheet> createState() =>
      _PhototherapyCompletionSheetState();
}

/// 单个治疗部位草稿。
class _PartDraft {
  _PartDraft()
    : nameController = TextEditingController(),
      minutesController = TextEditingController(),
      secondsController = TextEditingController();

  final String partId = newId();
  final TextEditingController nameController;
  final TextEditingController minutesController;
  final TextEditingController secondsController;
  final List<CarePhoto> photos = [];

  bool get isEmpty =>
      nameController.text.trim().isEmpty &&
      minutesController.text.trim().isEmpty &&
      secondsController.text.trim().isEmpty &&
      photos.isEmpty;

  void dispose() {
    nameController.dispose();
    minutesController.dispose();
    secondsController.dispose();
  }
}

class _PhototherapyCompletionSheetState
    extends ConsumerState<PhototherapyCompletionSheet> {
  final List<_PartDraft> _parts = [_PartDraft()];

  /// 同模板上一次已保存的部位记录（「应用上一次」数据源；null = 没有可复用记录）。
  List<PhototherapyExposurePart>? _lastParts;

  /// 上一次记录的完成时间（展示在按钮文案里，帮用户确认复用哪一次）。
  DateTime? _lastCompletedAt;

  @override
  void initState() {
    super.initState();
    _loadLastRecord();
  }

  /// 读取同模板最近一次带补充的已完成任务（周期光疗短周期内部位/时长通常相同）。
  Future<void> _loadLastRecord() async {
    final templateId = widget.task.templateId;
    if (templateId == null) return;
    final last = await ref
        .read(repositoryProvider)
        .lastSupplementedTaskForTemplate(
          widget.task.patientId,
          templateId,
          excludeTaskId: widget.task.id,
        );
    if (last == null || !mounted) return;
    final parts = phototherapyExposureParts(last.supplement);
    if (parts.isEmpty) return;
    setState(() {
      _lastParts = parts;
      _lastCompletedAt = last.completedAt;
    });
  }

  @override
  void dispose() {
    for (final part in _parts) {
      part.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RecordCompletionSheet(
      title: '记录本次光疗',
      description:
          '按治疗部位记录照射时长与照片（如 1 分半 = 1 分 30 秒）。'
          '时长按你的设备与医生方案执行，这里只做记录。',
      notesLabel: '本次备注（可选，如皮肤感受）',
      onSubmit: _submit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_lastParts != null) ...[
            SizedBox(height: SpacingTokens.x3),
            _buildApplyLastButton(),
          ],
          SizedBox(height: SpacingTokens.x4),
          for (var i = 0; i < _parts.length; i++) _buildPartCard(i),
          SizedBox(height: SpacingTokens.x2),
          GlassButton(
            expanded: true,
            type: GlassButtonType.glass,
            icon: Icons.add,
            onPressed: () => setState(() => _parts.add(_PartDraft())),
            child: const Text('添加部位'),
          ),
        ],
      ),
    );
  }

  /// 「应用上一次记录」按钮：一键带入同部位同短周期内通常不变的部位与时长。
  /// 照片不复用（每次治疗需重新拍摄才反映当前皮肤状态）。
  Widget _buildApplyLastButton() {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final summary = _lastParts!
        .map((p) {
          final d = formatDurationZh(p.durationSeconds);
          return d == null ? p.name : '${p.name} $d';
        })
        .join('；');
    final when = _lastCompletedAt == null
        ? ''
        : '（${DateFormat('M月d日').format(_lastCompletedAt!)}）';

    return GlassButton(
      expanded: true,
      type: GlassButtonType.glass,
      icon: Icons.replay,
      onPressed: _applyLastRecord,
      child: Text(
        '应用上一次记录$when：$summary',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.labelStyle.copyWith(color: colors.brand),
      ),
    );
  }

  /// 用上一次记录重建部位草稿（新 partId，不带照片）；已有输入时先确认。
  Future<void> _applyLastRecord() async {
    final hasInput = _parts.any((p) => !p.isEmpty);
    if (hasInput) {
      final ok = await showGlassConfirm(
        context,
        title: '应用上一次记录',
        message: '将用上一次治疗的部位与时长替换当前已填写的内容（照片不受影响）。',
        confirmLabel: '替换',
      );
      if (ok != true || !mounted) return;
    }
    setState(() {
      for (final p in _parts) {
        p.dispose();
      }
      _parts
        ..clear()
        ..addAll(
          _lastParts!.map((last) {
            final draft = _PartDraft()..nameController.text = last.name;
            final d = last.durationSeconds;
            if (d != null) {
              draft.minutesController.text = '${d ~/ 60}';
              final s = d % 60;
              if (s > 0) draft.secondsController.text = '$s';
            }
            return draft;
          }),
        );
    });
  }

  Widget _buildPartCard(int index) {
    final part = _parts[index];
    return Container(
      margin: EdgeInsets.only(bottom: SpacingTokens.x3),
      padding: EdgeInsets.all(SpacingTokens.x3),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<ColorTokens>()!.fillStrong,
        borderRadius: RadiusTokens.largeShape,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('部位 ${index + 1}', style: context.labelStyle),
              ),
              if (_parts.length > 1)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: '删除该部位',
                  onPressed: () => setState(() {
                    part.dispose();
                    _parts.removeAt(index);
                  }),
                ),
            ],
          ),
          SizedBox(height: SpacingTokens.x1),
          TextField(
            controller: part.nameController,
            decoration: const InputDecoration(
              labelText: '部位名称',
              hintText: '如 左前臂 / 颈部右侧',
            ),
          ),
          SizedBox(height: SpacingTokens.x2),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: part.minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '分'),
                ),
              ),
              SizedBox(width: SpacingTokens.x2),
              Expanded(
                child: TextField(
                  controller: part.secondsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '秒'),
                ),
              ),
              SizedBox(width: SpacingTokens.x2),
              Expanded(
                flex: 2,
                child: Text('照射时长\n留空表示未记录', style: context.captionStyle),
              ),
            ],
          ),
          SizedBox(height: SpacingTokens.x2),
          if (part.photos.isNotEmpty)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: part.photos.length,
                separatorBuilder: (_, _) => SizedBox(width: SpacingTokens.x2),
                itemBuilder: (context, photoIndex) {
                  final photo = part.photos[photoIndex];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => openPhotoViewer(context, photo),
                        child: ClipRRect(
                          borderRadius: RadiusTokens.smallShape,
                          child: Image.file(
                            File(photo.filePath),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            cacheWidth: 200,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removePhoto(part, photoIndex),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(2),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (part.photos.isNotEmpty) SizedBox(height: SpacingTokens.x2),
          GlassButton(
            expanded: true,
            type: GlassButtonType.glass,
            icon: Icons.photo_camera_outlined,
            onPressed: () => _addPhoto(part),
            child: const Text('拍/选该部位照片'),
          ),
        ],
      ),
    );
  }

  /// 移除已添加的照片并删除已复制到相册目录的文件（避免孤儿文件）。
  Future<void> _removePhoto(_PartDraft part, int index) async {
    final photo = part.photos[index];
    setState(() => part.photos.removeAt(index));
    try {
      final file = File(photo.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // 清理失败不阻塞交互。
    }
  }

  Future<void> _addPhoto(_PartDraft part) async {
    final photo = await PhotoCaptureSheet.show(
      context,
      patientId: widget.task.patientId,
      diseaseId: widget.task.diseaseId!,
      kind: PhotoKind.lesion,
    );
    if (photo == null) return;
    setState(() => part.photos.add(photo));
  }

  Future<RecordCompletionResult?> _submit({
    required bool skip,
    required String notes,
  }) async {
    // 收起输入法再提交，避免键盘遮挡提示。
    FocusScope.of(context).unfocus();

    final notesValue = notes.isEmpty ? null : notes;
    // 过滤空白部位行；时长非法文本视为未记录（不阻塞完成）。
    final parts = <_PartDraft>[
      for (final part in _parts)
        if (!part.isEmpty) part,
    ];
    TaskSupplement? supplement;
    // 照片只会跟随有部位名的记录入库；被丢弃行/「仅完成」的照片直接删文件。
    final repo = ref.read(repositoryProvider);
    final photoRowsToKeep = <CarePhoto>[];
    Future<void> discardFiles(List<CarePhoto> photos) async {
      for (final photo in photos) {
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

    if (!skip && parts.isNotEmpty) {
      final exposureParts = <PhototherapyExposurePart>[];
      for (final part in parts) {
        final name = part.nameController.text.trim();
        if (name.isEmpty) {
          // 无部位名 → 该行照片不保留（无引用即孤儿）。
          await discardFiles(part.photos);
          continue;
        }
        final minutes = int.tryParse(part.minutesController.text.trim());
        final seconds = int.tryParse(part.secondsController.text.trim());
        final duration = (minutes == null && seconds == null)
            ? null
            : ((minutes ?? 0) * 60 + (seconds ?? 0));
        exposureParts.add(
          PhototherapyExposurePart(
            partId: part.partId,
            name: name,
            durationSeconds: (duration == null || duration <= 0)
                ? null
                : duration,
            photoIds: [for (final photo in part.photos) photo.id],
          ),
        );
        photoRowsToKeep.addAll(part.photos);
      }
      if (exposureParts.isNotEmpty) {
        supplement = TaskSupplement(
          schema: kPhototherapyExposureSchema,
          content: <String, Object?>{
            'parts': [for (final part in exposureParts) part.toJson()],
          },
        );
      }
    } else {
      // 「仅完成」或没有任何记录 → 已拍摄的照片不留。
      for (final part in _parts) {
        await discardFiles(part.photos);
      }
    }

    // 有部位名的照片行入库（关联任务；删除补充记录时一并清理）。
    for (final photo in photoRowsToKeep) {
      if (supplement != null) {
        await repo.addCarePhoto(photo.copyWith(taskId: widget.task.id));
      } else {
        await discardFiles([photo]);
      }
    }
    return RecordCompletionResult(supplement: supplement, notes: notesValue);
  }
}
