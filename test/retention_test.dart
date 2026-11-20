import 'package:book_store_app/app/data/repositories/retention_repository.dart';
import 'package:book_store_app/app/modules/retention/views/retention_views.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Live (test buyer, 2026-11-20; link revoked right after):
// POST /api/wishlist-share -> {"active":true,"token":"<redacted>","url":"https://www.edudeen.com/wishlist/shared/<redacted>"}
// DELETE /api/wishlist-share -> {"active":false,"token":null,"url":null}
// GET /api/referrals/me -> {"enabled":false,"code":null,"shareUrl":null,"reward":{"type":"percentage","value":10,
//   "label":"10% off","friendLabel":null,"expiryDays":60},"stats":{"pending":0,"rewarded":0,"cap":10},"referredByAnyone":false}
class _FakeRepo extends RetentionRepository {
  _FakeRepo({this.referral = const {}, this.shared});
  final Map referral;
  final Object? shared; // List<Map> or an error
  @override
  Future<ReferralInfo> myReferral() async => ReferralInfo(referral);
  @override
  Future<List<Map>> sharedWishlist(String token) async => shared is List<Map> ? shared as List<Map> : throw shared!;
}

const _live = {
  'enabled': false, 'code': null, 'shareUrl': null,
  'reward': {'type': 'percentage', 'value': 10, 'label': '10% off', 'friendLabel': null, 'expiryDays': 60},
  'stats': {'pending': 0, 'rewarded': 0, 'cap': 10}, 'referredByAnyone': false,
};

Widget _app(Widget w) => GetMaterialApp(home: w);

void main() {
  test('share link parsing + endpoints', () {
    final s = WishlistShare.fromJson({'active': true, 'token': 't', 'url': 'https://www.edudeen.com/wishlist/shared/t'});
    expect(s.active, isTrue);
    expect(WishlistShare.fromJson({'active': false, 'token': null, 'url': null}).url, isNull);
    expect(ApiConstants.wishlistShare('mine'), endsWith('/wishlist-share/mine'));
    expect(ApiConstants.wishlistShare(''), endsWith('/wishlist-share'));
  });

  testWidgets('referrals disabled -> empty state', (t) async {
    await t.pumpWidget(_app(ReferralsView(repo: _FakeRepo(referral: _live))));
    await t.pumpAndSettle();
    expect(find.text('Referrals are not available right now'), findsOneWidget);
  });

  testWidgets('referrals enabled shows code, reward and apply box', (t) async {
    await t.pumpWidget(_app(ReferralsView(repo: _FakeRepo(referral: {..._live, 'enabled': true, 'code': 'ABC123', 'shareUrl': 'https://x/r/ABC123'}))));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('referralCode')), findsOneWidget);
    expect(find.textContaining('10% off'), findsOneWidget);
    await t.tap(find.text('Apply'));
    await t.pump();
    expect(find.text('Enter a code.'), findsOneWidget);
  });

  testWidgets('shared wishlist: empty and revoked link', (t) async {
    await t.pumpWidget(_app(SharedWishlistView(repo: _FakeRepo(shared: <Map>[]), token: 't')));
    await t.pumpAndSettle();
    expect(find.text('This wishlist is empty'), findsOneWidget);
    await t.pumpWidget(_app(SharedWishlistView(key: const Key('b'), repo: _FakeRepo(shared: Exception('404 This link is not available')), token: 't')));
    await t.pumpAndSettle();
    expect(find.text('This link is not available'), findsOneWidget);
  });
}
