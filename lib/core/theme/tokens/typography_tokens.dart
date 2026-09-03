import 'package:flutter/material.dart';

/// Typography 便捷扩展：一律映射到 `Theme.of(context).textTheme`（官方角色）。
///
/// 禁止在业务代码里直接构造 TextStyle；统一经 textTheme 角色或本扩展取值。
/// 迁移映射（旧尺度 → M3 角色，字号体系保持 34/28/22/16/14/12，见 app_theme）：
/// - displayStyle → displayLarge（页首大标题）
/// - titleStyle → headlineMedium（大节标题）
/// - headlineStyle → headlineSmall（区块标题）
/// - bodyStyle / bodyBoldStyle → bodyLarge（正文 / 加粗）
/// - labelStyle / labelBoldStyle → labelLarge（标签 / 强调标签）
/// - captionStyle / secondaryLabelStyle → 小字号次级文字
extension TypographyContext on BuildContext {
  TextTheme get _t => Theme.of(this).textTheme;
  ColorScheme get _c => Theme.of(this).colorScheme;

  TextStyle get displayStyle => _t.displayLarge!;
  TextStyle get titleStyle => _t.headlineMedium!;
  TextStyle get headlineStyle => _t.headlineSmall!;
  TextStyle get bodyStyle => _t.bodyLarge!;
  TextStyle get bodyBoldStyle => _t.bodyLarge!.copyWith(fontWeight: FontWeight.w600);
  TextStyle get labelStyle => _t.labelLarge!;
  TextStyle get labelBoldStyle => _t.labelLarge!.copyWith(fontWeight: FontWeight.w600);
  TextStyle get captionStyle => _t.bodySmall!.copyWith(color: _c.onSurfaceVariant);
  TextStyle get secondaryBodyStyle =>
      _t.bodyMedium!.copyWith(color: _c.onSurfaceVariant);
  TextStyle get secondaryLabelStyle =>
      _t.labelLarge!.copyWith(color: _c.onSurfaceVariant);
}
