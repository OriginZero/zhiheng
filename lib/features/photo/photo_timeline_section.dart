import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers/core_providers.dart';
import '../../app/providers/task_providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/domain/domain.dart';
import '../../shared/widgets/async_status_view.dart';
import '../../shared/widgets/glass/glass.dart';
import '../../shared/widgets/photo_viewer_page.dart';
import 'photo_capture_sheet.dart';

/// 光疗照片时间线（开发文档 §34）。
///
/// 横滑展示某疾病的患处照片（时间倒序），点击缩略图全屏查看；
/// 空状态引导完成治疗后拍下第一张照片。
class PhotoTimelineSection extends ConsumerWidget {
  const PhotoTimelineSection({super.key, required this.diseaseId});

  final String diseaseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider(diseaseId));
    return photos.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(SpacingTokens.x4),
          child: Text('照片加载失败', style: context.secondaryLabelStyle),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.photo_camera_outlined,
            title: '还没有照片',
            message: '完成治疗后拍下患处照片，长期对比变化。',
            action: GlassButton(
              icon: Icons.photo_camera_outlined,
              onPressed: () => _capture(context, ref),
              child: const Text('拍照'),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GlassButton(
                type: GlassButtonType.glass,
                icon: Icons.add,
                onPressed: () => _capture(context, ref),
                child: const Text('拍照'),
              ),
            ),
            SizedBox(height: SpacingTokens.x2),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, _) => SizedBox(width: SpacingTokens.x2),
                itemBuilder: (context, index) =>
                    _PhotoTile(photo: list[index]),
              ),
            ),
          ],
        );
      },
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

/// 时间线缩略图：底部叠加拍摄时机与日期，点击全屏查看。
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});

  final CarePhoto photo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openViewer(context),
      child: ClipRRect(
        borderRadius: RadiusTokens.mediumShape,
        child: SizedBox(
          width: 96,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(photo.filePath),
                fit: BoxFit.cover,
                cacheWidth: 400,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SpacingTokens.x2,
                    vertical: SpacingTokens.x1,
                  ),
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        photo.kind.labelZh,
                        style: context.captionStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('M/d').format(photo.takenAt),
                        style: context.captionStyle.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    openPhotoViewer(context, photo);
  }
}
