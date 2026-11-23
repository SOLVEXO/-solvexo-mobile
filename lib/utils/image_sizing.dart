import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Decode network images at the size they are shown (R3): a 4000 px cover
/// shown at 56 px otherwise costs ~64 MB of decoded pixels and jank while
/// scrolling. Returns null when the size is unknown/unbounded (decode as is).
class ImageSizing {
  ImageSizing._();

  static const int maxPx = 1600;

  static int? cachePx(BuildContext context, double? logical) {
    if (logical == null || !logical.isFinite || logical <= 0) return null;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    return math.min(maxPx, (logical * dpr).round());
  }
}
