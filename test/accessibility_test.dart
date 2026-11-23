import 'dart:math' as math;

import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/i18n/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _lum(Color c) {
  double f(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
}

double _contrast(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

void main() {
  testWidgets('icon button: 44 px target + screen-reader label', (t) async {
    final handle = t.ensureSemantics();
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: CustomIconButton(assetName: 'assets/icons/none.svg', size: 18, semanticLabel: 'Cart', onPressed: () {})),
      ),
    ));
    final size = t.getSize(find.byType(CustomIconButton));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
    expect(find.bySemanticsLabel('Cart'), findsOneWidget);
    await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
    handle.dispose();
  });

  test('secondary text colours reach WCAG AA (4.5:1) on white', () {
    for (final c in [AppColors.gray600, AppColors.grey, AppColors.lightGrey7, AppColors.green2, AppColors.primaryColor]) {
      expect(_contrast(c, Colors.white), greaterThanOrEqualTo(4.5), reason: '$c');
    }
  });

  test('legacy snake_case keys have real English and Urdu text', () {
    final k = AppTranslations().keys;
    for (final key in ['field', 'cannot_be_empty', 'is_too_short', 'lbl_delete_validation', 'address']) {
      expect(k['en_US']![key], isNotNull, reason: key);
      expect(k['ur_PK']![key], isNotNull, reason: key);
    }
  });
}
