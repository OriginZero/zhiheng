import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:zhiheng/core/theme/tokens/glass_tokens.dart';
import 'package:zhiheng/core/theme/tokens/radius_tokens.dart';

/// 玻璃材质级别（开发文档 §23）。
enum GlassLevel {
  /// 主玻璃表面：卡片、面板。
  surface,

  /// 交互元素：按钮、Chip、浮动控件。
  control,

  /// 导航栏。
  navigation,

  /// 弹层：Sheet / Dialog。
  overlay,
}

/// 所有玻璃效果的唯一实现（开发文档 §22、§49、§51）。
///
/// 业务页面只能使用 [GlassSurface] / [GlassCard] / [GlassButton] /
/// GlassNavigation / GlassSheet / GlassDialog，禁止在业务代码中直接写
/// BackdropFilter、ImageFilter.blur、渐变或阴影。
///
/// 性能约束：长列表中避免逐条使用带 blur 的玻璃卡片；
/// 高密度列表请使用 [GlassSurface.staticSurface]（无 BackdropFilter）。
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.level = GlassLevel.surface,
    this.borderRadius = RadiusTokens.largeShape,
    this.padding,
    this.margin,
    this.blur = true,
    this.tint,
  });

  /// 无 BackdropFilter 的静态玻璃表面，用于长列表等性能敏感场景。
  const GlassSurface.staticSurface({
    super.key,
    required this.child,
    this.borderRadius = RadiusTokens.largeShape,
    this.padding,
    this.margin,
    this.tint,
  })  : level = GlassLevel.surface,
        blur = false;

  final Widget child;
  final GlassLevel level;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool blur;

  /// 可选的着色，覆盖默认白色玻璃。
  final Color? tint;

  double get _blurSigma => switch (level) {
        GlassLevel.surface => GlassTokens.surfaceBlur,
        GlassLevel.control => GlassTokens.controlBlur,
        GlassLevel.navigation => GlassTokens.navigationBlur,
        GlassLevel.overlay => GlassTokens.overlayBlur,
      };

  double get _opacity => switch (level) {
        GlassLevel.surface => GlassTokens.surfaceOpacity,
        GlassLevel.control => GlassTokens.controlOpacity,
        GlassLevel.navigation => GlassTokens.navigationOpacity,
        GlassLevel.overlay => GlassTokens.overlayOpacity,
      };

  double get _borderOpacity => switch (level) {
        GlassLevel.surface => GlassTokens.surfaceBorderOpacity,
        GlassLevel.control => GlassTokens.controlBorderOpacity,
        GlassLevel.navigation => GlassTokens.surfaceBorderOpacity,
        GlassLevel.overlay => GlassTokens.surfaceBorderOpacity,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassColor =
        tint ?? (isDark ? const Color(0xFF2A2C30) : Colors.white);

    // 内容层：背景 + 边框 + 高光（无阴影）
    Widget content = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: glassColor.withValues(alpha: _opacity),
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: _borderOpacity),
          width: 0.75,
        ),
      ),
      // 顶部高光，保持玻璃的立体感。
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: GlassTokens.highlight,
      ),
      child: child,
    );

    // 模糊层：ClipRRect 只裁剪内容，不裁剪阴影
    if (blur) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _blurSigma,
            sigmaY: _blurSigma,
          ),
          child: content,
        ),
      );
    }

    // 阴影层：放在 ClipRRect 外部，避免被裁剪成直角
    if (level == GlassLevel.surface) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: GlassTokens.surfaceShadow,
        ),
        child: content,
      );
    }

    return content;
  }
}
