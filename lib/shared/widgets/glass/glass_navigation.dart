import 'package:flutter/material.dart';

import 'package:zhiheng/core/theme/tokens/color_tokens.dart';
import 'package:zhiheng/core/theme/tokens/motion_tokens.dart';
import 'package:zhiheng/core/theme/tokens/radius_tokens.dart';
import 'package:zhiheng/core/theme/tokens/spacing_tokens.dart';
import 'glass_surface.dart';

/// 底部导航项定义。
class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// 玻璃底部导航栏（开发文档 §22）。
///
/// 悬浮胶囊形态，Level: navigation。
class GlassNavigation extends StatelessWidget {
  const GlassNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.x4,
        SpacingTokens.x2,
        SpacingTokens.x4,
        SpacingTokens.x5,
      ),
      child: GlassSurface(
        level: GlassLevel.navigation,
        borderRadius: RadiusTokens.xlargeShape,
        padding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x2,
          vertical: SpacingTokens.x2,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == selectedIndex,
                    onTap: () => onTap(i),
                    selectedColor: colors.brand,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ColorTokens>()!;
    final foreground = selected ? selectedColor : colors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        borderRadius: RadiusTokens.largeShape,
        onTap: onTap,
        // 可访问性：足够的点击区域（开发文档 §30）。
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: SpacingTokens.x2,
          ),
          child: AnimatedDefaultTextStyle(
            duration: MotionTokens.fast,
            curve: MotionTokens.enter,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  size: 22,
                  color: foreground,
                ),
                SizedBox(height: SpacingTokens.x1),
                Text(item.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
