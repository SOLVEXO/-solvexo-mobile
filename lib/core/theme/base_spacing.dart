/// 8-point spacing scale used across every redesigned screen — pick from
/// here instead of hardcoding `SizedBox(height: 14)` style magic numbers.
class BaseSpacing {
  BaseSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 56;

  /// Standard screen edge padding.
  static const double screenPadding = md;
}

/// Corner-radius scale.
class BaseRadius {
  BaseRadius._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}
