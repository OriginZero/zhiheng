import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/domain.dart';

/// 全屏查看照片（黑底、原图可缩放），只专注图片本身（§34）。
///
/// 所有照片缩略图入口共用：光疗照片时间线、任务详情弹层的执行补充、
/// 光疗完成弹层的拍摄草稿。黑底全屏路由，无额外信息层。
class PhotoViewerPage extends StatelessWidget {
  const PhotoViewerPage({super.key, required this.photo});

  final CarePhoto photo;

  @override
  Widget build(BuildContext context) {
    // 全屏照片查看器是黑底图像展示页：黑底 / 白色前景属于图像覆盖语义
    // （照片上的遮罩与文字），不是主题表面色，按项目约定保留字面量。
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: Image.file(File(photo.filePath), fit: BoxFit.contain),
        ),
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
