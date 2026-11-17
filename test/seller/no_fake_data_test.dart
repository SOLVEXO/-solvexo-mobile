import 'package:book_store_app/app/modules/seller_settings/controllers/seller_settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('More tab starts empty: no invented profile, plan, store or zones', () {
    final c = SellerSettingsController(); // onInit not run: no network
    expect(c.name.value, isEmpty);
    expect(c.email.value, isEmpty);
    expect(c.plan.value, isEmpty);
    expect(c.storeName.value, isEmpty);
  });

  test('mock-only screens are not offered', () {
    final titles = SellerSettingsController()
        .sections
        .expand((s) => s.tiles)
        .map((t) => t.title)
        .toList();
    expect(titles, isNot(contains('Two-Factor Auth')));
    expect(titles, isNot(contains('Language')));
    expect(titles, isNot(contains('Shipping')));
    expect(titles, contains('Switch to buyer account'));
  });
}
