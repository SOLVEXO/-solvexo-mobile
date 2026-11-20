import 'dart:async';

import 'package:book_store_app/app/routes/deep_link_router.dart';
import 'package:flutter/foundation.dart';

/// One entry point for every link that reaches the app from outside: push
/// notification taps (foreground / background / terminated) and, from R2,
/// App Links / Universal Links. Links that arrive before the first screen
/// is up (cold start) are held and opened once the splash has navigated.
class IncomingLinks {
  IncomingLinks._();

  static String? _pending;
  static bool _ready = false;
  static String? _last;
  static DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Opener; tests swap it.
  @visibleForTesting
  static bool Function(String link) opener = DeepLinkRouter.open;

  /// Push `data.link`, or any edudeen.com URL / path.
  static void handle(String? link) {
    if (link == null || link.trim().isEmpty) return;
    final l = link.trim();
    // The same link can arrive twice (initial link + stream, or local
    // notification + FCM): ignore repeats within 3 seconds.
    final now = DateTime.now();
    if (l == _last && now.difference(_lastAt) < const Duration(seconds: 3)) return;
    _last = l;
    _lastAt = now;
    if (!_ready) {
      _pending = l;
      return;
    }
    opener(l);
  }

  /// Called by the splash once the first real screen is shown.
  static void markReady() {
    _ready = true;
    final p = _pending;
    _pending = null;
    if (p != null) Timer(const Duration(milliseconds: 400), () => opener(p));
  }

  @visibleForTesting
  static void reset() {
    _pending = null;
    _ready = false;
    _last = null;
    _lastAt = DateTime.fromMillisecondsSinceEpoch(0);
    opener = DeepLinkRouter.open;
  }

  @visibleForTesting
  static String? get pending => _pending;
}
