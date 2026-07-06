import 'package:flutter/material.dart';
import 'base_colors.dart';

/// Elevation presets — soft, layered shadows instead of Material's default
/// flat elevation, used by [BaseDecorations] and premium card widgets.
class BaseShadows {
  BaseShadows._();

  static const List<BoxShadow> none = [];

  static List<BoxShadow> xs = [
    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static List<BoxShadow> sm = [
    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
  ];

  static List<BoxShadow> md = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 6)),
  ];

  static List<BoxShadow> lg = [
    BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 30, offset: const Offset(0, 12)),
  ];

  /// Tinted "glow" shadow for primary CTAs — a Stripe/Linear-style accent.
  static List<BoxShadow> glow([Color color = BaseColors.primary]) => [
        BoxShadow(color: color.withOpacity(0.28), blurRadius: 20, offset: const Offset(0, 8)),
      ];
}
