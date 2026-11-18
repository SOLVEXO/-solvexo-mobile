import 'package:book_store_app/app/modules/seller/utils/seller_link_router.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:flutter_test/flutter_test.dart';

// data.link values from the test seller's real notifications (2026-11-17).
void main() {
  test('real seller links map to seller screens', () {
    expect(SellerLinkRouter.routeFor('/store/6abb8ddb6ae49762491d5302/products'),
        Routes.sellerProducts);
    expect(SellerLinkRouter.routeFor('/store/6abb8ddb6ae49762491d5302/orders'),
        Routes.sellerOrders);
  });

  test('platform_campaign_live opens Platform Sales (#12)', () {
    expect(SellerLinkRouter.routeFor('/store/6abb8ddb6ae49762491d5302/marketing?tab=platform'),
        Routes.sellerPlatformSales);
    expect(SellerLinkRouter.routeFor('/store/6abb8ddb6ae49762491d5302/marketing/sale/6abc'),
        Routes.sellerPlatformSales);
  });

  test('links without a matching seller screen stay on the inbox', () {
    expect(SellerLinkRouter.routeFor('/store/6abb8ddb6ae49762491d5302/marketing'), isNull);
    expect(SellerLinkRouter.routeFor('/account/orders/123'), isNull, reason: 'buyer link');
    expect(SellerLinkRouter.routeFor(null), isNull);
    expect(SellerLinkRouter.routeFor(''), isNull);
  });
}
