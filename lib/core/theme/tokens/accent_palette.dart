import 'package:flutter/material.dart';

/// 强调色主题（Material 3 seed）。
///
/// 每套主题提供 [brand] 作为 `ColorScheme.fromSeed` 的 seed 色，
/// 亮/暗两套 ColorScheme 均由 Material 3 从该 seed 派生（官方 tonal palette），
/// 页面一律经 `Theme.of(context).colorScheme` 取色。
/// 医疗产品约束：低饱和、克制，颜色服务于层级而非装饰。
class AccentPalette {
  const AccentPalette({
    required this.id,
    required this.labelZh,
    required this.brand,
    required this.onBrand,
  });

  final String id;
  final String labelZh;

  /// seed 主色（设置页色板圆与主题派生共用）。
  final Color brand;

  /// seed 色上的可读前景色（色板选中勾）。
  final Color onBrand;
}

/// 内置强调色（低饱和适配，均满足在浅色 seed 上放白色勾选标记的对比度）。
abstract final class AccentPalettes {
  /// 海盐蓝（默认）。
  static const AccentPalette ocean = AccentPalette(
    id: 'ocean',
    labelZh: '海盐蓝',
    brand: Color(0xFF4F7C8C),
    onBrand: Color(0xFFFFFFFF),
  );

  /// 薰衣草紫。
  static const AccentPalette lavender = AccentPalette(
    id: 'lavender',
    labelZh: '薰衣草紫',
    brand: Color(0xFF7A6FA6),
    onBrand: Color(0xFFFFFFFF),
  );

  /// 薄荷青。
  static const AccentPalette mint = AccentPalette(
    id: 'mint',
    labelZh: '薄荷青',
    brand: Color(0xFF3E8E8C),
    onBrand: Color(0xFFFFFFFF),
  );

  /// 珊瑚橙。
  static const AccentPalette coral = AccentPalette(
    id: 'coral',
    labelZh: '珊瑚暖橙',
    brand: Color(0xFFB0695A),
    onBrand: Color(0xFFFFFFFF),
  );

  /// 鼠尾草绿。
  static const AccentPalette sage = AccentPalette(
    id: 'sage',
    labelZh: '鼠尾草绿',
    brand: Color(0xFF6E8C5F),
    onBrand: Color(0xFFFFFFFF),
  );

  static const List<AccentPalette> all = [
    ocean,
    lavender,
    mint,
    coral,
    sage,
  ];

  /// 按 id 取主题，未知/空回退默认 [ocean]。
  static AccentPalette byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => ocean);
}
