import 'package:book_store_app/app/services/legal_links.dart';
import 'package:book_store_app/app/services/notification_ask.dart';
import 'package:book_store_app/app/services/permission_rationale.dart';
import 'package:book_store_app/core/i18n/app_translations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Live 2026-11-23: https://www.edudeen.com/privacy-policy, /terms-of-service and
// /delete-account -> 200; the apex https://edudeen.com/... -> 308 to www.
void main() {
  test('legal pages are the www URLs the store listings use', () {
    expect(LegalLinks.privacyPolicy, 'https://www.edudeen.com/privacy-policy');
    expect(LegalLinks.termsOfService, 'https://www.edudeen.com/terms-of-service');
    expect(LegalLinks.deleteAccount, 'https://www.edudeen.com/delete-account');
  });

  test('permission explanations exist in Urdu', () {
    final ur = AppTranslations().keys['ur_PK']!;
    for (final k in PermissionKind.values) {
      expect(ur[PermissionRationale.title(k)], isNotNull, reason: '$k title');
      expect(ur[PermissionRationale.body(k)], isNotNull, reason: '$k body');
    }
  });

  test('notification explanation: once, then again after 7 days', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await NotificationAsk.shouldAsk(), isTrue);
    await NotificationAsk.markAsked();
    expect(await NotificationAsk.shouldAsk(), isFalse);
    expect(await NotificationAsk.shouldAsk(now: DateTime.now().add(const Duration(days: 8))), isTrue);
  });
}
