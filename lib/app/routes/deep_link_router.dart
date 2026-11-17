import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Turns an Edudeen web path (notification `data.link`, push payload, shared
/// URL) into an in-app route. Unknown paths return `false` so the caller can
/// fall back (e.g. stay on the inbox). Never throws.
///
/// Supported (docs §10): /product/:slug, /shop/:slug, /account/orders[/:id],
/// /account/downloads, /account/dashboard?openChat=1, /wishlist,
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
        case 'shop':
          if (seg.length > 1) {
            Get.toNamed(Routes.sellerStorefront, arguments: {'slug': seg[1]});
            return true;
          }
          return false;
        case 'wishlist':
          Get.toNamed(Routes.WISHLIST);
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
              Get.toNamed(Routes.myOrdersView);
              return true;
            case 'wishlist':
              Get.toNamed(Routes.WISHLIST);
              return true;
            case 'addresses':
              Get.toNamed(Routes.addressView);
              return true;
            default:
              if (q['openChat'] == '1') {
                Get.toNamed(Routes.helpCenterView);
              } else {
                Get.toNamed(Routes.profileView);
              }
              return true;
          }
        default:
          return false;
      }
    } catch (e) {
      debugPrint('DeepLinkRouter: cannot open "$link": $e');
      return false;
    }
  }
}
