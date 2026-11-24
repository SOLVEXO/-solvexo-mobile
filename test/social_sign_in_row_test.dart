import 'package:book_store_app/app/components/social_sign_in_row.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_test/flutter_test.dart';

// Google everywhere; Sign in with Apple only on iOS.
void main() {
  Widget row({bool? apple}) => ResponsiveSizer(
        builder: (_, __, ___) => MaterialApp(
          home: Scaffold(
            body: SocialSignInRow(onGoogle: () {}, onApple: () {}, isBusy: false, activeProvider: '', appleEnabled: apple),
          ),
        ),
      );

  testWidgets('non-iOS -> Google only', (t) async {
    await t.pumpWidget(row());
    expect(find.byKey(const Key('socialGoogle')), findsOneWidget);
    expect(find.byKey(const Key('socialApple')), findsNothing);
  });

  testWidgets('iOS -> Apple shows next to Google', (t) async {
    await t.pumpWidget(row(apple: true));
    expect(find.byKey(const Key('socialApple')), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });
}
