import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Turns an Edudeen web path (notification `data.link`, push payload, shared
/// URL) into an in-app route. Unknown paths return `false` so the caller can
/// fall back (e.g. stay on the inbox). Never throws.
///
/// Supported (docs §10): /product/:slug, /shop/:slug, /course/:slug, /certificates/:code, /wishlist/shared/:token, /account/orders[/:id],
/// /account/downloads, /account/dashboard?openChat=1, /account/reviews,
/// /account/premium, /cart, /bundles/:slug, /picks/:slug, /learning-paths[/:slug], /store/:storeId/<area> (seller), /wishlist,
/// /notifications, /messages, /?category=, /?campaign=, /?search=.
class DeepLinkRouter {
  DeepLinkRouter._();

  static bool open(String? link) {
    if (link == null || link.trim().isEmpty) return false;
    try {
      final raw = link.trim();
      final uri = raw.startsWith('http')
          ? Uri.parse(raw)
          : Uri.parse(raw.startsWith('/') ? raw : '/$raw');
      // Only follow our own links; anything else is ignored.
      if (uri.hasAuthority && !uri.host.endsWith('edudeen.com')) return false;
      final seg = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      final q = uri.queryParameters;

      if (seg.isEmpty) {
        if (q['category'] != null || q['campaign'] != null ||
            q['search'] != null || q['q'] != null) {
          Get.toNamed(Routes.searchView, arguments: Map<String, String>.from(q));
          return true;
        }
        Get.offAllNamed(Routes.mainHome);
        return true;
      }

      switch (seg.first) {
        case 'product':
          if (seg.length > 1) {
            Get.toNamed(Routes.productDetailsView,
                arguments: {'productId': seg[1]});
            return true;
          }
          return false;
        case 'course':
          if (seg.length > 1) {
            Get.toNamed(Routes.coursePlayer, arguments: {'slug': seg[1]});
            return true;
          }
          return false;
        case 'certificates':
          if (seg.length > 1) {
            Get.toNamed(Routes.certificateView, arguments: {'code': seg[1]});
            return true;
          }
          return false;
        case 'premium':
          Get.toNamed(Routes.premium);
          return true;
        case 'shop':
          if (seg.length > 1) {
            Get.toNamed(Routes.sellerStorefront, arguments: {'slug': seg[1]});
            return true;
          }
          return false;
        case 'wishlist':
          if (seg.length > 2 && seg[1] == 'shared') {
            Get.toNamed(Routes.sharedWishlist, arguments: {'token': seg[2]});
          } else {
            Get.toNamed(Routes.WISHLIST);
          }
          return true;
        case 'notifications':
          Get.toNamed(Routes.notifications);
          return true;
        case 'messages':
          final conv = q['conv'];
          if (conv != null && conv.isNotEmpty) {
            Get.toNamed(Routes.chatView, arguments: {'conversationId': conv});
          } else {
            Get.toNamed(Routes.messagesView);
          }
          return true;
        case 'account':
          final sub = seg.length > 1 ? seg[1] : 'dashboard';
          switch (sub) {
            case 'orders':
              Get.toNamed(Routes.myOrdersView,
                  arguments: seg.length > 2 ? {'orderId': seg[2]} : null);
              return true;
            case 'downloads':
              Get.toNamed(Routes.library);
              return true;
            case 'wishlist':
              Get.toNamed(Routes.WISHLIST);
              return true;
            case 'children':
              Get.toNamed(Routes.children);
              return true;
            case 'reviews':
              Get.toNamed(Routes.myReviews);
              return true;
            case 'premium':
              Get.toNamed(Routes.premium);
              return true;
            case 'referrals':
              Get.toNamed(Routes.referrals);
              return true;
            case 'addresses':
              Get.toNamed(Routes.addressView);
              return true;
            default:
              if (q['openChat'] == '1') {
                Get.toNamed(Routes.supportChat);
              } else {
                Get.toNamed(Routes.profileView);
              }
              return true;
          }
        case 'cart':
          Get.toNamed(Routes.cartView);
          return true;
        case 'bundles':
        case 'picks':
          if (seg.length > 1) {
            Get.toNamed(Routes.shelf, arguments: {'kind': seg.first == 'bundles' ? 'bundle' : 'picks', 'slug': seg[1]});
            return true;
          }
          return false;
        case 'learning-paths':
          if (seg.length > 1) {
            Get.toNamed(Routes.shelf, arguments: {'kind': 'learningPath', 'slug': seg[1]});
          } else {
            Get.toNamed(Routes.learningPaths);
          }
          return true;
        // Seller notification links: /store/:storeId/<area>.
        case 'store':
          final area = seg.length > 2 ? seg[2] : 'dashboard';
          final route = switch (area) {
            'orders' => Routes.sellerOrders,
            'returns' => Routes.sellerReturns,
            'products' || 'categories' => Routes.sellerProducts,
            'inventory' => Routes.sellerInventory,
            'marketing' => Routes.sellerPromotions,
            'plan-billing' => Routes.sellerPlatformPlan,
            'ai' => Routes.sellerAiStudio,
            _ => Routes.sellerHome,
          };
          Get.toNamed(route);
          return true;
        default:
          return false;
      }
    } catch (e) {
      debugPrint('DeepLinkRouter: cannot open "$link": $e');
      return false;
    }
  }
}
