import 'package:book_store_app/core/theme/base_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved app language. Urdu switches the whole app to RTL (Material handles
/// mirroring once `ur` is the locale) and to the Nastaliq font (see
/// `BaseTheme`).
class LocaleService {
  LocaleService._();

  static const english = Locale('en', 'US');
  static const urdu = Locale('ur', 'PK');
  static const supported = [english, urdu];
  static const _key = 'app_language_code';

  static Locale _current = english;
  static Locale get current => _current;
  static bool get isUrdu => _current.languageCode == 'ur';

  /// Call once before runApp.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _current = prefs.getString(_key) == 'ur' ? urdu : english;
  }

  static Future<void> setUrdu(bool urduOn) async {
    _current = urduOn ? urdu : english;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _current.languageCode);
    // Theme first so the font (Inter vs Nastaliq) changes with the language.
    Get.changeTheme(BaseTheme.build(Brightness.light, urdu: urduOn));
    await Get.updateLocale(_current);
  }
}
