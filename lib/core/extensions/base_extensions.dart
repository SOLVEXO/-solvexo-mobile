import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Context shortcuts used throughout the redesigned screens — avoids
/// repeating `Theme.of(context).colorScheme` / `MediaQuery.of(context)` etc.
extension BaseContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  /// True once the on-screen keyboard is open (viewInsets.bottom > 0).
  bool get isKeyboardOpen => viewInsets.bottom > 0;

  void dismissKeyboard() => FocusScope.of(this).unfocus();
}

/// A "design-time" scaling unit distinct from `responsive_sizer`'s `.w`/`.h`
/// (which are percentage-of-screen units): `.r` scales a value designed at a
/// 375-logical-pixel-wide reference frame to the current device, which is
/// the more predictable choice for corner radii and icon sizes.
extension BaseResponsiveX on num {
  double get r => this * (Device.width / 375.0);
}
