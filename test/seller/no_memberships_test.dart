import 'dart:io';

import 'package:book_store_app/app/modules/seller_settings/controllers/seller_settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

// Backend 5adba44 removed /api/subscriptions/* (store memberships, commit
// eee3d8a) and /api/products/education/*. The app must not call them.
void main() {
  test('no removed endpoints in ApiConstants', () {
    final src = File('lib/app/network/api_constaints.dart').readAsStringSync();
    expect(src, isNot(contains('/subscriptions/')));
    expect(src, isNot(contains('/education/')));
    expect(src, isNot(contains('educationLevel')));
    expect(src.toLowerCase(), isNot(contains('booking')));
  });

  test('no membership screens or tiles', () {
    final titles = SellerSettingsController().sections.expand((s) => s.tiles).map((t) => t.title);
    expect(titles, isNot(contains('Subscription Plans')));
    expect(Directory('lib/app/modules/my_memberships').existsSync(), isFalse);
    expect(Directory('lib/app/modules/seller_subscriptions').existsSync(), isFalse);
    expect(File('lib/app/modules/storefront/widgets/storefront_plans_teaser.dart').existsSync(), isFalse);
  });
}
