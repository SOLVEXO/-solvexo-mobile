import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

/// Premium, dark-mode-ready color tokens for the new `core/` design system.
///
/// This is an *evolution* of [AppColors], not a replacement — every existing
/// screen still using [AppColors] keeps working unchanged. [BaseColors]
/// layers semantic, theme-aware tokens (surface/onSurface/border, gradients,
/// elevation overlays) on top of the same brand palette so newly-redesigned
/// screens and legacy screens still look like one product.
class BaseColors {
  BaseColors._();

  // ── Brand (same source of truth as AppColors) ─────────────────────────────
  static const Color primary = AppColors.primaryColor;
  static const Color primaryLight = AppColors.primaryColorLight;
  static const Color accent = AppColors.accentColor;
  static const Color secondary = AppColors.secondryColor;

  /// Deep brand navy for headings, hero panels and the selected nav pill.
  static const Color ink = Color(0xFF0F2742);

  /// Warm brand gold (minaret/crescent) for highlights and sale accents.
  static const Color gold = Color(0xFFE9B23C);

  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF1F4F86)],
  );

  /// Brand hero (was a coral gradient left over from the old template).
  static const Gradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F4F86), primary, Color(0xFF4C8FD3)],
  );

  // ── Semantic (light) ───────────────────────────────────────────────────────
  static const Color surfaceLight = AppColors.white;
  static const Color surfaceVariantLight = Color(0xFFF1F5FA);
  static const Color backgroundLight = Color(0xFFF6F8FB);
  static const Color onSurfaceLight = Color(0xFF14202E);
  static const Color onSurfaceMutedLight = Color(0xFF5B6B7F);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = AppColors.dividerColor;

  // ── Semantic (dark) ─────────────────────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2E);
  static const Color backgroundDark = Color(0xFF121214);
  static const Color onSurfaceDark = Color(0xFFF2F2F2);
  static const Color onSurfaceMutedDark = Color(0xFFA1A1A6);
  static const Color borderDark = Color(0xFF38383A);
  static const Color dividerDark = Color(0xFF2C2C2E);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = AppColors.greenSuccess;
  static const Color warning = AppColors.amberDark;
  static const Color danger = AppColors.error;
  static const Color info = AppColors.iosBlue;

  // ── Glass / overlay ────────────────────────────────────────────────────────
  static Color glassLight = AppColors.white.withOpacity(0.72);
  static Color glassDark = const Color(0xFF1C1C1E).withOpacity(0.72);
  static Color scrim = AppColors.black.withOpacity(0.45);
}
