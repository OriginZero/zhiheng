import 'package:flutter/widgets.dart';

/// 统一圆角令牌（开发文档 §27）。
///
/// 组件不得单独设置圆角，一律从这里取值。
abstract final class RadiusTokens {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 20;
  static const double xlarge = 28;
  static const double pill = 999;

  static const BorderRadius smallShape =
      BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumShape =
      BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeShape =
      BorderRadius.all(Radius.circular(large));
  static const BorderRadius xlargeShape =
      BorderRadius.all(Radius.circular(xlarge));
  static const BorderRadius pillShape =
      BorderRadius.all(Radius.circular(pill));
}
