import 'package:book_store_app/app/routes/app_pages.dart';

/// Maps a seller notification's web `data.link` (`/store/<storeId>/<area>...`,
/// e.g. `/store/6abb.../products`, `/store/6abb.../marketing?tab=platform`)
/// to a seller screen the app has. Null when there is no matching screen.
class SellerLinkRouter {
  SellerLinkRouter._();

  static const Map<String, String> _areas = {
    'products': Routes.sellerProducts,
    'orders': Routes.sellerOrders,
    'returns': Routes.sellerReturns,
    'finance': Routes.sellerFinance,
    'plan': Routes.sellerPlatformPlan,
    'billing': Routes.sellerPlatformPlan,
    'plan-expired': Routes.sellerPlanExpired,
    'analytics': Routes.sellerAnalytics,
    'messages': Routes.sellerMessages,
    'promotions': Routes.sellerPromotions,
  };

  static String? routeFor(String? link) {
    if (link == null || link.isEmpty) return null;
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    final seg = uri.pathSegments;
    if (seg.length < 3 || seg[0] != 'store') return null;
    return _areas[seg[2]];
  }
}
