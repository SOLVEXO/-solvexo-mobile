import 'package:book_store_app/core/theme/base_theme.dart';
import 'package:flutter/material.dart';

/// Thin compatibility shim: every screen still reaches theme via
/// `AppTheme.lightTheme`/`AppTheme.darkTheme` through `main.dart`, so both
/// now delegate straight to [BaseTheme] — the single source of truth for
/// the redesigned design system (colors, typography, spacing, component
/// theming) described in `lib/core/theme/`.
class AppTheme {
  static ThemeData get lightTheme => BaseTheme.light;
  static ThemeData get darkTheme => BaseTheme.dark;
}
