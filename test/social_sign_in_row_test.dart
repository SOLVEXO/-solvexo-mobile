import 'package:book_store_app/app/components/social_sign_in_row.dart';
import 'package:book_store_app/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_test/flutter_test.dart';

// Facebook sign-in is shown only when the build has FACEBOOK_APP_ID.
void main() {
  Widget row({bool? enabled}) => ResponsiveSizer(
        builder: (_, __, ___) => MaterialApp(
          home: Scaffold(
            body: SocialSignInRow(onGoogle: () {}, onFacebook: () {}, isBusy: false, activeProvider: '', facebookEnabled: enabled),
          ),
        ),
      );

  testWidgets('no FACEBOOK_APP_ID -> Google only', (t) async {
    expect(AppConfig.facebookLoginEnabled, isFalse, reason: 'tests run without the define');
    await t.pumpWidget(row());
    expect(find.byKey(const Key('socialGoogle')), findsOneWidget);
    expect(find.byKey(const Key('socialFacebook')), findsNothing);
  });

  testWidgets('with an app id -> Facebook shows next to Google', (t) async {
    await t.pumpWidget(row(enabled: true));
    expect(find.byKey(const Key('socialFacebook')), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
  });
}
