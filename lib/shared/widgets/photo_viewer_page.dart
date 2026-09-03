import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../domain/domain.dart';

/// 全屏查看照片（原图可缩放）+ 拍摄引导通过项列表（§34）。
///
/// 所有照片缩略图入口共用：光疗照片时间线、任务详情弹层的执行补充、
/// 光疗完成弹层的拍摄草稿。黑底全屏路由，AppBar 展示拍摄时机与时间。
class PhotoViewerPage extends StatelessWidget {
  const PhotoViewerPage({super.key, required this.photo});

  final CarePhoto photo;

  @override
  Widget build(BuildContext context) {
    // 全屏照片查看器是黑底图像展示页：黑底 / 白色前景属于图像覆盖语义
    // （照片上的遮罩与文字），不是主题表面色，按项目约定保留字面量。
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${photo.kind.labelZh} · '
          '${DateFormat('yyyy/M/d HH:mm').format(photo.takenAt)}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                maxScale: 4,
                child: Image.file(File(photo.filePath), fit: BoxFit.contain),
              ),
            ),
          ),
          if (photo.guidePassed.isNotEmpty)
            // 底部说明条叠在照片黑底上，白字属图像覆盖语义（见上注释）。
            Container(
              width: double.infinity,
              color: Colors.black,
              padding: EdgeInsets.all(SpacingTokens.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '拍摄引导通过项',
                    style: context.labelBoldStyle.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: SpacingTokens.x2),
                  for (final key in photo.guidePassed)
                    Padding(
                      padding: EdgeInsets.only(bottom: SpacingTokens.x1),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: colors.success,
                          ),
                          SizedBox(width: SpacingTokens.x2),
                          Text(
                            photoGuideLabel(key),
                            style: context.bodyStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 全屏查看照片的统一入口：缩略图点击处都走这里，避免重复路由代码。
void openPhotoViewer(BuildContext context, CarePhoto photo) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => PhotoViewerPage(photo: photo)),
  );
}
