import 'package:flutter/material.dart';

/// 医疗状态语义色令牌（Material 3 未覆盖角色）。
///
/// ColorScheme 之外的固定语义色：正常/注意/警告/严重/良好。
/// 明暗各一套，均满足与对应表面色 ≥ 4.5:1 的文字对比；UI 不得只靠颜色
/// 传达信息，须配合图标/文字/形状。其余颜色角色一律经
/// `Theme.of(context).colorScheme`，禁止在本类追加非状态角色。
class ColorTokens extends ThemeExtension<ColorTokens> {
  const ColorTokens({
    required this.normal,
    required this.attention,
    required this.warning,
    required this.critical,
    required this.success,
  });

  final Color normal;
  final Color attention;
  final Color warning;
  final Color critical;
  final Color success;

  /// 按亮度取一套状态色。
  factory ColorTokens.status({required bool dark}) => dark
      ? const ColorTokens(
          normal: Color(0xFF94A3B8),
          attention: Color(0xFFFBBF24),
          warning: Color(0xFFFB923C),
          critical: Color(0xFFF2B8B5),
          success: Color(0xFF4ADE80),
        )
      : const ColorTokens(
          normal: Color(0xFF475569),
          attention: Color(0xFF92400E),
          warning: Color(0xFF9A3412),
          critical: Color(0xFFB3261E),
          success: Color(0xFF15803D),
        );

  @override
  ColorTokens copyWith() => this;

  @override
  ColorTokens lerp(covariant ColorTokens? other, double t) {
    if (other == null) return this;
    return ColorTokens(
      normal: Color.lerp(normal, other.normal, t)!,
      attention: Color.lerp(attention, other.attention, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}
