import 'package:flutter/animation.dart';

/// 统一动效令牌（开发文档 §28）。
///
/// 动画要求：快、克制、有目的。时长与曲线集中在此，业务页面不得自定义。
abstract final class MotionTokens {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);

  /// 元素进入（出现、展开）。
  static const Curve enter = Curves.easeOutCubic;

  /// 元素退出（收起、关闭）。
  static const Curve exit = Curves.easeInCubic;
}
