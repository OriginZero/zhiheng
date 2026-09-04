import 'package:flutter/material.dart';

import 'tokens/accent_palette.dart';
import 'tokens/color_tokens.dart';
import 'tokens/radius_tokens.dart';
import 'tokens/spacing_tokens.dart';

/// 应用统一主题（Material 3，Flutter 官方 Design System）。
///
/// 构建策略：
/// - [ColorScheme] 一律由 `ColorScheme.fromSeed` 从 [AccentPalette.brand] 派生，
///   亮/暗两套均走 Material 3 tonal palette（页面不再手写表面色）；
/// - 业务代码经 `Theme.of(context).colorScheme / textTheme` 与下方组件主题取样式，
///   禁止裸 `Color(...)` / `TextStyle(...)` / `BorderRadius` 字面量；
/// - [ColorTokens] 为 M3 无法表达的业务语义色（医疗状态色）常驻扩展，
///   亮/暗各一套、带配套前景角色；其余一律用 [ColorScheme]；
/// - 视觉规范与 Token 对照见 docs/UI风格文档.md。
abstract final class AppTheme {
  static ThemeData light([AccentPalette palette = AccentPalettes.ocean]) =>
      _build(palette, Brightness.light);

  static ThemeData dark([AccentPalette palette = AccentPalettes.ocean]) =>
      _build(palette, Brightness.dark);

  static ThemeData _build(AccentPalette palette, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.brand,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(),
      extensions: [
        ColorTokens.status(dark: isDark),
      ],
      // ---- AppBar：纯色面，无玻璃 ----
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _textTheme().titleLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      // ---- 底部导航：官方 NavigationBar ----
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      // ---- 卡片：subtle filled card（M3） ----
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.mediumShape,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.x4,
        ),
      ),
      inputDecorationTheme: _inputDecoration(scheme),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 0.5,
        space: 1,
      ),
      // ---- 底部弹层：M3 showModalBottomSheet（顶圆角 + surfaceContainerLow 面） ----
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.xlarge),
          ),
        ),
        modalBackgroundColor: scheme.surfaceContainerLow,
        modalBarrierColor: Colors.black.withValues(alpha: 0.32),
      ),
      // ---- 对话框 ----
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.xlargeShape,
        ),
        titleTextStyle: _textTheme().titleLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
        contentTextStyle: _textTheme().bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: _textTheme().bodyMedium?.copyWith(
              color: scheme.onInverseSurface,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: RadiusTokens.mediumShape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          textStyle: _textTheme().labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          textStyle: _textTheme().labelLarge,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 44),
          textStyle: _textTheme().labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  /// 统一字号体系（系统字体；中文医疗场景克制层级）。
  ///
  /// 尺寸沿用项目既有尺度（34/28/22/16/14/12），角色名对齐 Material 3 官方
  /// TextTheme。未覆盖角色维持 Flutter 官方默认，业务页只允许使用本表角色
  /// 及官方 `bodyMedium`/`titleMedium` 等小号角色。
  static TextTheme _textTheme() {
    const w600 = FontWeight.w600;
    const w700 = FontWeight.w700;
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: w700, height: 1.15),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: w700, height: 1.2),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: w600, height: 1.25),
      titleLarge: TextStyle(fontSize: 22, fontWeight: w600, height: 1.3),
      titleMedium: TextStyle(fontSize: 16, fontWeight: w600, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
    );
  }

  /// 输入框统一主题：filled（M3 surfaceContainerHighest 底）+ outline 边框。
  ///
  /// 填充/文字/光标/占位符颜色全部取自 [ColorScheme]，保证明暗两模式对比度；
  /// 输入正文继承 textTheme.bodyLarge（最高对比度 onSurface）。
  static InputDecorationThemeData _inputDecoration(ColorScheme scheme) {
    final border = OutlineInputBorder(
      borderRadius: RadiusTokens.mediumShape,
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    return InputDecorationThemeData(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      focusColor: scheme.primary,
      hoverColor: scheme.primary.withValues(alpha: 0.08),
      border: border,
      enabledBorder: border,
      errorBorder: OutlineInputBorder(
        borderRadius: RadiusTokens.mediumShape,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: RadiusTokens.mediumShape,
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: RadiusTokens.mediumShape,
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: scheme.primary),
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      helperStyle: TextStyle(color: scheme.onSurfaceVariant),
      errorStyle: TextStyle(color: scheme.error),
      iconColor: scheme.onSurfaceVariant,
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.x4,
        vertical: SpacingTokens.x3,
      ),
    );
  }
}
