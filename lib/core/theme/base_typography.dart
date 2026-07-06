import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'base_colors.dart';

/// Material 3 type scale for the premium redesign — built on the same
/// `Inter` font family already used by [AppTextStyles] so legacy and
/// redesigned screens share one typographic voice.
class BaseTypography {
  BaseTypography._();

  static const String fontFamily = AppTextStyles.fontFamily;

  static TextStyle _s(double size, FontWeight weight, {double? height, Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? BaseColors.onSurfaceLight,
        letterSpacing: size >= 24 ? -0.4 : 0,
      );

  static TextStyle displayLarge({Color? color}) => _s(34, FontWeight.w800, height: 1.15, color: color);
  static TextStyle displayMedium({Color? color}) => _s(28, FontWeight.w800, height: 1.2, color: color);

  static TextStyle headlineLarge({Color? color}) => _s(24, FontWeight.w700, height: 1.25, color: color);
  static TextStyle headlineMedium({Color? color}) => _s(20, FontWeight.w700, height: 1.3, color: color);
  static TextStyle headlineSmall({Color? color}) => _s(18, FontWeight.w600, height: 1.3, color: color);

  static TextStyle titleLarge({Color? color}) => _s(17, FontWeight.w600, height: 1.3, color: color);
  static TextStyle titleMedium({Color? color}) => _s(15, FontWeight.w600, height: 1.35, color: color);
  static TextStyle titleSmall({Color? color}) => _s(13, FontWeight.w600, height: 1.35, color: color);

  static TextStyle bodyLarge({Color? color}) => _s(16, FontWeight.w400, height: 1.45, color: color);
  static TextStyle bodyMedium({Color? color}) => _s(14, FontWeight.w400, height: 1.45, color: color);
  static TextStyle bodySmall({Color? color}) => _s(12.5, FontWeight.w400, height: 1.4, color: color);

  static TextStyle labelLarge({Color? color}) => _s(14, FontWeight.w600, height: 1.2, color: color);
  static TextStyle labelMedium({Color? color}) => _s(12, FontWeight.w600, height: 1.2, color: color);
  static TextStyle labelSmall({Color? color}) => _s(11, FontWeight.w600, height: 1.2, color: color);

  static TextTheme textTheme(Brightness brightness) {
    final onSurface = brightness == Brightness.dark ? BaseColors.onSurfaceDark : BaseColors.onSurfaceLight;
    return TextTheme(
      displayLarge: displayLarge(color: onSurface),
      displayMedium: displayMedium(color: onSurface),
      headlineLarge: headlineLarge(color: onSurface),
      headlineMedium: headlineMedium(color: onSurface),
      headlineSmall: headlineSmall(color: onSurface),
      titleLarge: titleLarge(color: onSurface),
      titleMedium: titleMedium(color: onSurface),
      titleSmall: titleSmall(color: onSurface),
      bodyLarge: bodyLarge(color: onSurface),
      bodyMedium: bodyMedium(color: onSurface),
      bodySmall: bodySmall(color: onSurface),
      labelLarge: labelLarge(color: onSurface),
      labelMedium: labelMedium(color: onSurface),
      labelSmall: labelSmall(color: onSurface),
    );
  }
}
