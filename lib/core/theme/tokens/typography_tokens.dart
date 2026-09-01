import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// 统一 Typography 令牌（开发文档 §25）。
///
/// 使用系统字体（iOS SF Pro / Android Roboto），所有页面遵循同一 Scale。
abstract final class TypographyTokens {
  static const String _fontFamily = ''; // 空字符串 = 系统字体

  static const double displaySize = 34;
  static const double titleSize = 28;
  static const double headlineSize = 22;
  static const double bodySize = 16;
  static const double labelSize = 14;
  static const double captionSize = 12;

  static TextStyle display(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: displaySize,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: color,
      );

  static TextStyle title(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: titleSize,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
      );

  static TextStyle headline(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: headlineSize,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: color,
      );

  static TextStyle body(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodyBold(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: bodySize,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: color,
      );

  static TextStyle label(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: labelSize,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: color,
      );

  static TextStyle labelBold(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: labelSize,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  static TextStyle caption(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: captionSize,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: color,
      );
}

/// 从 BuildContext 便捷取用排版样式的扩展。
extension TypographyContext on BuildContext {
  ColorTokens get _colors => Theme.of(this).extension<ColorTokens>()!;

  TextStyle get displayStyle => TypographyTokens.display(_colors.textPrimary);
  TextStyle get titleStyle => TypographyTokens.title(_colors.textPrimary);
  TextStyle get headlineStyle =>
      TypographyTokens.headline(_colors.textPrimary);
  TextStyle get bodyStyle => TypographyTokens.body(_colors.textPrimary);
  TextStyle get bodyBoldStyle => TypographyTokens.bodyBold(_colors.textPrimary);
  TextStyle get labelStyle => TypographyTokens.label(_colors.textPrimary);
  TextStyle get labelBoldStyle =>
      TypographyTokens.labelBold(_colors.textPrimary);
  TextStyle get captionStyle => TypographyTokens.caption(_colors.textTertiary);
  TextStyle get secondaryBodyStyle =>
      TypographyTokens.body(_colors.textSecondary);
  TextStyle get secondaryLabelStyle =>
      TypographyTokens.label(_colors.textSecondary);
}
