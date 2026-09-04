import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../domain/domain.dart';
import 'photo_viewer_page.dart';

/// 方形照片缩略预览（§34 照片统一预览组件）。
///
/// 收敛光疗完成弹层、任务详情、疾病照片时间线里各处手写的缩略图：
/// - 统一尺寸 / 圆角 / 加载占位（scheme 底色，避免白/黑块）；
/// - 底部按需叠加「拍摄时机 · 日期」浮签（图像覆盖语义，白色文字例外）；
/// - 右上按需叠加移除角标（拍摄草稿预览场景）；
/// - 整卡点击 → 全屏查看（openPhotoViewer）。
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({
    super.key,
    required this.photo,
    this.size = 96,
    this.showMeta = false,
    this.onRemove,
    this.removeTooltip = '删除照片',
  });

  final CarePhoto photo;

  /// 缩略图边长（方形，4 的倍数；点击区随尺寸缩放）。
  final double size;

  /// 底部是否叠加「时机 · 日期」浮签（归档/时间线等场景）。
  final bool showMeta;

  /// 提供后右上角出现移除角标（仅草稿预览：未入库照片可直接删文件）。
  final VoidCallback? onRemove;

  final String removeTooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => openPhotoViewer(context, photo),
      child: ClipRRect(
        borderRadius: RadiusTokens.mediumShape,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(photo.filePath),
                fit: BoxFit.cover,
                cacheWidth: (size * 3).round(),
                // 图片加载失败占位：底色用 scheme，避免白/黑块。
                errorBuilder: (_, _, _) => ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: scheme.outline,
                  ),
                ),
              ),
              if (showMeta)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SpacingTokens.x2,
                      vertical: SpacingTokens.x1,
                    ),
                    // 照片上的半透明遮罩与白色文字 = 图像覆盖语义
                    // （本文件裸 Colors.* 的唯一允许场景）。
                    color: Colors.black.withValues(alpha: 0.45),
                    child: Text(
                      '${photo.kind.labelZh} · '
                      '${DateFormat('M/d').format(photo.takenAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.captionStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              if (onRemove != null)
                Positioned(
                  top: SpacingTokens.x1,
                  right: SpacingTokens.x1,
                  child: Semantics(
                    button: true,
                    label: removeTooltip,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        // 覆盖在照片上的黑色圆角标 + 白色图标（图像覆盖语义例外）。
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
