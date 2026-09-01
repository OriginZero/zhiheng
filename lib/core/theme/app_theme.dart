import 'package:flutter/material.dart';

import 'tokens/color_tokens.dart';
import 'tokens/radius_tokens.dart';
import 'tokens/spacing_tokens.dart';
import 'tokens/typography_tokens.dart';

/// 应用统一主题（开发文档 §21、§48）。
///
/// 所有页面从 [AppTheme] 获取 [ThemeData]；颜色一律经 [ColorTokens]，
/// 禁止在业务代码中出现裸的 Color(...) / TextStyle(...) / BorderRadius。
abstract final class AppTheme {
  static ThemeData light() => _build(ColorTokens.light, Brightness.light);
  static ThemeData dark() => _build(ColorTokens.dark, Brightness.dark);

  static ThemeData _build(ColorTokens tokens, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: tokens.brand,
        onPrimary: tokens.onBrand,
        secondary: tokens.brand,
        onSecondary: tokens.onBrand,
        surface: tokens.backgroundBase,
        onSurface: tokens.textPrimary,
        error: tokens.critical,
        onError: tokens.onBrand,
      ),
      scaffoldBackgroundColor: tokens.backgroundBase,
      dividerColor: tokens.divider,
      extensions: [tokens],
      textTheme: _textTheme(tokens),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TypographyTokens.headline(tokens.textPrimary),
        iconTheme: IconThemeData(color: tokens.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.largeShape,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: tokens.textSecondary,
        textColor: tokens.textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: SpacingTokens.x4,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.divider,
        thickness: 0.5,
        space: 1,
      ),
    );
  }

  static TextTheme _textTheme(ColorTokens tokens) {
    return TextTheme(
      displayLarge: TypographyTokens.display(tokens.textPrimary),
      displayMedium: TypographyTokens.title(tokens.textPrimary),
      headlineMedium: TypographyTokens.headline(tokens.textPrimary),
      bodyLarge: TypographyTokens.body(tokens.textPrimary),
      bodyMedium: TypographyTokens.body(tokens.textPrimary),
      labelLarge: TypographyTokens.labelBold(tokens.textPrimary),
      labelMedium: TypographyTokens.label(tokens.textPrimary),
      bodySmall: TypographyTokens.caption(tokens.textTertiary),
    );
  }
}
