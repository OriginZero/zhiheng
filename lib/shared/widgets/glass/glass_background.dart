import 'package:flutter/material.dart';

import 'package:zhiheng/core/theme/tokens/color_tokens.dart';

/// Level 1 背景层（开发文档 §23）：柔和渐变 + 环境光斑。
///
/// 每个页面共享同一背景，保证玻璃表面有内容可模糊。
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.backgroundGradientStart,
            colors.backgroundBase,
            colors.backgroundGradientEnd,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // 环境光斑：低饱和、大半径，营造柔和氛围。
          Positioned(
            top: -80,
            right: -60,
            child: _AmbientGlow(
              color: colors.brand.withValues(alpha: 0.10),
              size: 260,
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: _AmbientGlow(
              color: colors.attention.withValues(alpha: 0.07),
              size: 220,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
