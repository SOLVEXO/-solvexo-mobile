import 'package:flutter/material.dart';
import 'base_colors.dart';
import 'base_spacing.dart';
import 'base_typography.dart';

/// Material 3 theme for the buyer app — the single source of truth that
/// `AppTheme.lightTheme`/`darkTheme` delegate to.
///
/// Modern look: cool neutral background, white surfaces with a hairline
/// outline instead of shadows, pill-shaped primary actions, tonal chips,
/// a Material 3 navigation bar with a navy selection pill, and 44 px minimum
/// touch targets everywhere (docs §10). Urdu switches the type family to
/// Noto Nastaliq with taller lines.
class BaseTheme {
  BaseTheme._();

  static ThemeData get light => build(Brightness.light);
  static ThemeData get dark => build(Brightness.dark);

  static ThemeData build(Brightness brightness, {bool urdu = false}) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? BaseColors.surfaceDark : BaseColors.surfaceLight;
    final background = isDark ? BaseColors.backgroundDark : BaseColors.backgroundLight;
    final onSurface = isDark ? BaseColors.onSurfaceDark : BaseColors.onSurfaceLight;
    final muted = isDark ? BaseColors.onSurfaceMutedDark : BaseColors.onSurfaceMutedLight;
    final border = isDark ? BaseColors.borderDark : BaseColors.borderLight;
    final variant = isDark ? BaseColors.surfaceVariantDark : BaseColors.surfaceVariantLight;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: BaseColors.primary,
      brightness: brightness,
      primary: BaseColors.primary,
      secondary: BaseColors.secondary,
      tertiary: BaseColors.gold,
      surface: surface,
      error: BaseColors.danger,
    ).copyWith(
      outline: border,
      outlineVariant: border,
      onSurfaceVariant: muted,
      surfaceContainerHighest: variant,
    );

    final textTheme = BaseTypography.textTheme(brightness, urdu: urdu);
    const minTap = Size(44, 44);
    final pill = RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseRadius.pill));
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseRadius.md));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: urdu ? BaseTypography.urduFontFamily : BaseTypography.fontFamily,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      dividerColor: isDark ? BaseColors.dividerDark : BaseColors.dividerLight,
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: onSurface, size: 22),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BaseColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: pill,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BaseColors.primary,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: border),
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: minTap, shape: pill),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: minTap),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: variant,
        selectedColor: colorScheme.primaryContainer,
        side: BorderSide.none,
        shape: pill,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(64, 44),
          shape: pill,
          side: BorderSide(color: border),
          selectedBackgroundColor: BaseColors.ink,
          selectedForegroundColor: Colors.white,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: muted,
        labelStyle: textTheme.titleSmall,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(BaseRadius.pill),
          border: Border.all(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: isDark ? colorScheme.primaryContainer : BaseColors.ink,
        indicatorShape: pill,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected)
                  ? (isDark ? colorScheme.onPrimaryContainer : Colors.white)
                  : muted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            (textTheme.labelSmall ?? const TextStyle()).copyWith(
              color: states.contains(WidgetState.selected) ? onSurface : muted,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            )),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: BaseSpacing.xs,
        minTileHeight: 52,
        iconColor: muted,
        shape: rounded,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: variant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(BaseRadius.md), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(BaseRadius.md), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BaseRadius.md),
          borderSide: const BorderSide(color: BaseColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BaseRadius.md),
          borderSide: const BorderSide(color: BaseColors.danger, width: 1.2),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: BaseColors.primary,
        linearMinHeight: 6,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(BaseRadius.xl)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseRadius.xl)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseRadius.md)),
      ),
    );
  }
}
