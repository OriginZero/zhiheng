import 'package:flutter/material.dart';

import 'package:zhiheng/core/theme/tokens/radius_tokens.dart';
import 'package:zhiheng/core/theme/tokens/spacing_tokens.dart';
import 'glass_surface.dart';

/// 玻璃卡片：业务页面的主要内容容器（Level 2）。
///
/// 使用方式：`GlassCard(child: ...)`。
/// 视觉实现全部集中在 Design System，业务页面不配置任何玻璃参数。
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;

  /// 默认内边距：16。传 [EdgeInsets.zero] 可以取消。
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = GlassSurface.staticSurface(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: SpacingTokens.x4,
            vertical: SpacingTokens.x4,
          ),
      margin: margin,
      child: child,
    );

    if (onTap == null) return surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: RadiusTokens.largeShape,
        onTap: onTap,
        child: surface,
      ),
    );
  }
}
