import 'package:flutter/material.dart';

import 'accent_palette.dart';

/// 统一颜色令牌。
///
/// 设计原则（开发文档 §24）：
/// - 中性背景 + 低饱和品牌色 + 疾病状态色；
/// - 状态颜色语义固定：normal / attention / warning / critical / success；
/// - UI 中不得只靠颜色传达信息，必须配合图标、文字或形状。
///
/// 品牌色由 [AccentPalette]（iOS 26 tint 风格主题）驱动：
/// 亮暗模式 + 5 套强调色自由组合。
class ColorTokens extends ThemeExtension<ColorTokens> {
  const ColorTokens({
    required this.backgroundBase,
    required this.backgroundGradientStart,
    required this.backgroundGradientEnd,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brand,
    required this.brandStrong,
    required this.onBrand,
    required this.divider,
    required this.normal,
    required this.attention,
    required this.warning,
    required this.critical,
    required this.success,
    required this.paletteId,
  });

  /// 应用背景基色。
  final Color backgroundBase;

  /// 背景渐变起始 / 结束色（Level 1 环境层）。
  final Color backgroundGradientStart;
  final Color backgroundGradientEnd;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  /// 品牌主色（亮色模式）。
  final Color brand;

  /// 品牌亮色（暗色模式下的高亮版本）。
  final Color brandStrong;

  /// 品牌色之上的前景色。
  final Color onBrand;

  final Color divider;

  // ---- 语义状态色（固定含义，不得挪用） ----
  final Color normal;
  final Color attention;
  final Color warning;
  final Color critical;
  final Color success;

  /// 当前强调色主题 id（用于主题切换 UI）。
  final String paletteId;

  /// 亮色模式 + 指定强调色。
  static ColorTokens light(AccentPalette palette) => ColorTokens(
        backgroundBase: Color(0xFFF4F4F6),
        backgroundGradientStart: palette.ambientStart,
        backgroundGradientEnd: palette.ambientEnd,
        textPrimary: Color(0xFF1C1C1E),
        textSecondary: Color(0xFF55555C),
        textTertiary: Color(0xFF8E8E95),
        brand: palette.brand,
        brandStrong: palette.brandStrong,
        onBrand: palette.onBrand,
        divider: Color(0x1F1C1C1E),
        normal: Color(0xFF6E7B86),
        attention: Color(0xFFB7791F),
        warning: Color(0xFFC2683B),
        critical: Color(0xFFBE4B42),
        success: Color(0xFF3E8E5A),
        paletteId: palette.id,
      );

  /// 暗色模式 + 指定强调色。
  static ColorTokens dark(AccentPalette palette) => ColorTokens(
        backgroundBase: Color(0xFF0E0F11),
        backgroundGradientStart: palette.brand.withValues(alpha: 0.18),
        backgroundGradientEnd: Color(0xFF15110D),
        textPrimary: Color(0xFFF2F2F4),
        textSecondary: Color(0xFFA6A6AE),
        textTertiary: Color(0xFF6E6E76),
        brand: palette.brandStrong,
        brandStrong: palette.brandStrong,
        onBrand: Color(0xFF0E0F11),
        divider: Color(0x1FFFFFFF),
        normal: Color(0xFF8A97A1),
        attention: Color(0xFFD9A648),
        warning: Color(0xFFD98A5A),
        critical: Color(0xFFD97066),
        success: Color(0xFF6FBF8F),
        paletteId: palette.id,
      );

  @override
  ColorTokens copyWith() => this;

  @override
  ColorTokens lerp(covariant ColorTokens? other, double t) {
    if (other == null) return this;
    return ColorTokens(
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      backgroundGradientStart:
          Color.lerp(backgroundGradientStart, other.backgroundGradientStart, t)!,
      backgroundGradientEnd:
          Color.lerp(backgroundGradientEnd, other.backgroundGradientEnd, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandStrong: Color.lerp(brandStrong, other.brandStrong, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      normal: Color.lerp(normal, other.normal, t)!,
      attention: Color.lerp(attention, other.attention, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      success: Color.lerp(success, other.success, t)!,
      paletteId: other.paletteId,
    );
  }
}
