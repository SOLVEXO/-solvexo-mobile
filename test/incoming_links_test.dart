import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/routes/deep_link_router.dart';
import 'package:book_store_app/app/routes/incoming_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Backend push payloads (firebase.config.ts sendToUser): data = notify()'s
// `data`, e.g. {orderId, orderNumber, link:'/account/reviews'} or
// {storeId, link:'/store/<id>/dashboard'}. Device token: POST/DELETE
// /api/notifications/device-token {fcmToken, platform: android|ios|web}.
void main() {
  setUp(IncomingLinks.reset);

  test('cold start: link waits for the first screen, then opens once', () async {
    final opened = <String>[];
    IncomingLinks.opener = (l) {
      opened.add(l);
      return true;
    };
    IncomingLinks.handle('/account/orders/abc');
    IncomingLinks.handle('/account/orders/abc'); // FCM + local duplicate
    expect(opened, isEmpty);
    expect(IncomingLinks.pending, '/account/orders/abc');
    IncomingLinks.markReady();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(opened, ['/account/orders/abc']);
  });

  test('warm app: opens immediately; empty links ignored', () {
    final opened = <String>[];
    IncomingLinks.opener = (l) {
      opened.add(l);
      return true;
    };
    IncomingLinks.markReady();
    IncomingLinks.handle(null);
    IncomingLinks.handle('  ');
    IncomingLinks.handle('https://www.edudeen.com/course/basic-computer-skills-course');
    expect(opened, ['https://www.edudeen.com/course/basic-computer-skills-course']);
  });

  testWidgets('router maps backend notification links', (t) async {
    await t.pumpWidget(GetMaterialApp(
      initialRoute: '/',
      unknownRoute: GetPage(name: '/x', page: () => const SizedBox()),
      getPages: [GetPage(name: '/', page: () => const SizedBox())],
    ));
    final cases = {
      '/account/reviews': Routes.myReviews,
      '/account/premium': Routes.premium,
      '/cart': Routes.cartView,
      '/store/6abb/orders': Routes.sellerOrders,
      '/store/6abb/plan-billing': Routes.sellerPlatformPlan,
      '/store/6abb/dashboard': Routes.sellerHome,
      'https://edudeen.com/wishlist/shared/tok': Routes.sharedWishlist,
      // R2 app-link paths
      'https://www.edudeen.com/product/p1': Routes.productDetailsView,
      'https://edudeen.com/shop/jami-store': Routes.sellerStorefront,
      'https://edudeen.com/course/basic-computer-skills-course': Routes.coursePlayer,
      'https://edudeen.com/certificates/EDU-8C00AFD7': Routes.certificateView,
      'https://edudeen.com/account/orders': Routes.myOrdersView,
      'https://edudeen.com/bundles/starter-set': Routes.shelf,
      'https://edudeen.com/picks/eid-gifts': Routes.shelf,
      'https://edudeen.com/learning-paths/grade-1': Routes.shelf,
      'https://edudeen.com/learning-paths': Routes.learningPaths,
      'https://edudeen.com/?category=books': Routes.searchView,
      'https://edudeen.com/?campaign=6abc': Routes.searchView,
    };
    for (final e in cases.entries) {
      expect(DeepLinkRouter.open(e.key), isTrue, reason: e.key);
      await t.pump();
      expect(Get.currentRoute, e.value, reason: e.key);
    }
    expect(DeepLinkRouter.open('https://evil.example/product/x'), isFalse);
    expect(DeepLinkRouter.open('javascript:alert(1)'), isFalse);
  });
}
