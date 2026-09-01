import 'package:flutter/material.dart';

import 'package:zhiheng/core/theme/tokens/color_tokens.dart';
import 'package:zhiheng/core/theme/tokens/motion_tokens.dart';
import 'package:zhiheng/core/theme/tokens/radius_tokens.dart';
import 'package:zhiheng/core/theme/tokens/spacing_tokens.dart';
import 'glass_surface.dart';

/// 玻璃按钮（Level 3 交互元素）。
///
/// 类型：
/// - [GlassButtonType.primary]：品牌色，主操作；
/// - [GlassButtonType.glass]：玻璃质感，次操作；
/// - [GlassButtonType.plain]：文字按钮。
enum GlassButtonType { primary, glass, plain }

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.type = GlassButtonType.primary,
    this.expanded = false,
    this.icon,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final GlassButtonType type;

  /// 是否撑满宽度。
  final bool expanded;

  /// 可选前置图标。
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    Widget content = AnimatedScale(
      duration: MotionTokens.fast,
      curve: MotionTokens.enter,
      scale: onPressed == null ? 0.98 : 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x5,
          vertical: SpacingTokens.x3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              SizedBox(width: SpacingTokens.x2),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );

    final label = DefaultTextStyle(
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
            color: switch (type) {
              GlassButtonType.primary => colors.onBrand,
              GlassButtonType.glass => colors.textPrimary,
              GlassButtonType.plain => colors.brand,
            },
          ),
      textAlign: TextAlign.center,
      child: IconTheme(
        data: IconThemeData(
          size: 18,
          color: switch (type) {
            GlassButtonType.primary => colors.onBrand,
            GlassButtonType.glass => colors.textPrimary,
            GlassButtonType.plain => colors.brand,
          },
        ),
        child: content,
      ),
    );

    Widget button;
    switch (type) {
      case GlassButtonType.primary:
        button = GlassSurface(
          level: GlassLevel.control,
          borderRadius: RadiusTokens.pillShape,
          tint: colors.brand,
          blur: false,
          padding: EdgeInsets.zero,
          child: label,
        );
      case GlassButtonType.glass:
        button = GlassSurface(
          level: GlassLevel.control,
          borderRadius: RadiusTokens.pillShape,
          padding: EdgeInsets.zero,
          child: label,
        );
      case GlassButtonType.plain:
        button = label;
    }

    final hitTarget = Semantics(
      button: true,
      enabled: onPressed != null,
      child: InkWell(
        borderRadius: type == GlassButtonType.plain
            ? RadiusTokens.smallShape
            : RadiusTokens.pillShape,
        onTap: onPressed,
        child: button,
      ),
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: hitTarget);
    }
    return hitTarget;
  }
}
