import 'package:book_store_app/core/i18n/locale_service.dart';
import 'package:book_store_app/core/theme/base_theme.dart';
import 'package:flutter/material.dart';

/// Compatibility shim: `main.dart` reads `AppTheme.lightTheme/darkTheme`,
/// both built by [BaseTheme]. Re-read on every locale change, so switching
/// to Urdu also switches the font.
class AppTheme {
  static ThemeData get lightTheme =>
      BaseTheme.build(Brightness.light, urdu: LocaleService.isUrdu);
  static ThemeData get darkTheme =>
      BaseTheme.build(Brightness.dark, urdu: LocaleService.isUrdu);
}
