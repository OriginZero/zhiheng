import 'package:flutter/material.dart';

/// 玻璃材质参数令牌（开发文档 §22、§23）。
///
/// 所有玻璃组件必须从这套参数取值，业务页面不得自行配置
/// BackdropFilter / blur / gradient / shadow。
///
/// 层级约束：最多 3 级。
/// - Level 1：背景（渐变 / 柔色场）
/// - Level 2：主玻璃表面（卡片、面板）
/// - Level 3：交互元素（按钮、Chip、浮动控件）
abstract final class GlassTokens {
  // Level 2 —— 主表面
  static const double surfaceBlur = 28;
  static const double surfaceOpacity = 0.62;
  static const double surfaceBorderOpacity = 0.22;

  // Level 3 —— 交互元素
  static const double controlBlur = 18;
  static const double controlOpacity = 0.5;
  static const double controlBorderOpacity = 0.28;

  // 导航栏：悬浮胶囊形态。玻璃面透明度与 surface 同级（0.62），
  // 并在浅色模式下用发丝描边勾勒轮廓——白玻璃贴米白背景仅靠明度差不可辨，
  // 无轮廓时胶囊会隐形，只剩背景长块观感（v1.9.1-1.9.3 曾误将胶囊当背景反复降透明到 0.1）。
  static const double navigationBlur = 32;
  static const double navigationOpacity = 0.62;

  /// 浅色模式导航胶囊的发丝描边（近黑 12%），替代不可见的白色描边。
  static const Color navigationBorderLight = Color(0x1F1C1E1E);

  // 弹层（Sheet / Dialog）
  static const double overlayBlur = 30;
  static const double overlayOpacity = 0.85;

  /// 玻璃表面统一阴影：克制、单层。
  static const List<BoxShadow> surfaceShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  /// 玻璃高光：顶部一道微弱亮边。
  static const LinearGradient highlight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x29FFFFFF), Color(0x00FFFFFF)],
    stops: [0.0, 0.25],
  );
}
