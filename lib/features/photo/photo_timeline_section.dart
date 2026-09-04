import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/photo_thumb.dart';
import 'photo_capture_sheet.dart';

/// 疾病照片时间线（开发文档 §34）。
///
/// 横滑展示某疾病的照片（时间倒序），缩略图点击全屏查看；
/// 空状态引导拍下第一张照片。
class PhotoTimelineSection extends ConsumerWidget {
  const PhotoTimelineSection({super.key, required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider(diseaseId));
    return AsyncStatusView(
      value: photos,
      emptyState: EmptyState(
        icon: Icons.photo_camera_outlined,
        title: '还没有照片',
        message: '完成治疗后拍下患处照片，长期对比变化。',
        action: FilledButton.icon(
          icon: const Icon(Icons.photo_camera_outlined),
          onPressed: () => _capture(context, ref),
          label: const Text('拍照'),
        ),
      ),
      builder: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.add),
              onPressed: () => _capture(context, ref),
              label: const Text('拍照'),
            ),
          ),
          SizedBox(height: SpacingTokens.x2),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, _) => SizedBox(width: SpacingTokens.x2),
              itemBuilder: (context, index) =>
                  PhotoThumb(photo: list[index], size: 112, showMeta: true),
            ),
          ),
        ],
      ),
    );
  }

  /// 打开拍摄弹层，成功后保存照片记录。
  Future<void> _capture(BuildContext context, WidgetRef ref) async {
    final photo = await PhotoCaptureSheet.show(
      context,
      patientId: localPatientId,
      diseaseId: diseaseId,
      kind: PhotoKind.after,
    );
    if (photo == null) return;
    await ref.read(repositoryProvider).addCarePhoto(photo);
  }
}
