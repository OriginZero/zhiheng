import 'package:flutter/material.dart';

/// iOS 26 风格强调色（tint）主题。
///
/// 设计依据：iOS 26 / Liquid Glass 引入系统级可自定义强调色，
/// 玻璃面板随强调色渲染（Adaptive Colors）。
/// 医疗产品约束（§24）：低饱和、克制，颜色服务于层级而非装饰。
/// 这里提供的是「低饱和适配版」tint，非 Apple 官方精确值。
class AccentPalette {
  const AccentPalette({
    required this.id,
    required this.labelZh,
    required this.brand,
    required this.brandStrong,
    required this.onBrand,
    required this.ambientStart,
    required this.ambientEnd,
  });

  final String id;
  final String labelZh;

  /// 品牌主色（按钮、选中态、图标）。
  final Color brand;

  /// 深色背景下更亮的品牌色。
  final Color brandStrong;

  /// 品牌色上的前景色。
  final Color onBrand;

  /// 背景环境渐变起止色（Level 1 环境光）。
  final Color ambientStart;
  final Color ambientEnd;

  Color brandFor(Brightness brightness) =>
      brightness == Brightness.dark ? brandStrong : brand;
}

/// 内置强调色主题（iOS 26 tint 风格，低饱和适配）。
abstract final class AccentPalettes {
  /// 海盐蓝（默认，沿用既有品牌色）。
  static const AccentPalette ocean = AccentPalette(
    id: 'ocean',
    labelZh: '海盐蓝',
    brand: Color(0xFF4F7C8C),
    brandStrong: Color(0xFF7FB0C0),
    onBrand: Color(0xFFFFFFFF),
    ambientStart: Color(0xFFEDF1F6),
    ambientEnd: Color(0xFFF7F3EE),
  );

  /// 薰衣草紫。
  static const AccentPalette lavender = AccentPalette(
    id: 'lavender',
    labelZh: '薰衣草紫',
    brand: Color(0xFF7A6FA6),
    brandStrong: Color(0xFFB3A8E0),
    onBrand: Color(0xFFFFFFFF),
    ambientStart: Color(0xFFF1EEF7),
    ambientEnd: Color(0xFFF7F3EF),
  );

  /// 薄荷青。
  static const AccentPalette mint = AccentPalette(
    id: 'mint',
    labelZh: '薄荷青',
    brand: Color(0xFF3E8E8C),
    brandStrong: Color(0xFF6FC4C0),
    onBrand: Color(0xFFFFFFFF),
    ambientStart: Color(0xFFEDF5F4),
    ambientEnd: Color(0xFFF4F7EF),
  );

  /// 珊瑚暖橙。
  static const AccentPalette coral = AccentPalette(
    id: 'coral',
    labelZh: '珊瑚暖橙',
    brand: Color(0xFFB0695A),
    brandStrong: Color(0xFFE09A88),
    onBrand: Color(0xFFFFFFFF),
    ambientStart: Color(0xFFF8F1EE),
    ambientEnd: Color(0xFFF6F4EF),
  );

  /// 鼠尾草绿。
  static const AccentPalette sage = AccentPalette(
    id: 'sage',
    labelZh: '鼠尾草绿',
    brand: Color(0xFF6E8C5F),
    brandStrong: Color(0xFFA3C08F),
    onBrand: Color(0xFFFFFFFF),
    ambientStart: Color(0xFFF0F5EC),
    ambientEnd: Color(0xFFF6F4EF),
  );

  static const List<AccentPalette> all = [
    ocean,
    lavender,
    mint,
    coral,
    sage,
  ];

  /// 按 id 查找；未知 id 回退默认。
  static AccentPalette byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => ocean);
}
