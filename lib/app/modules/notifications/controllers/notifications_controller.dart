import 'dart:async';

import 'package:book_store_app/app/data/models/common_models/notification_model.dart';
import 'package:book_store_app/app/data/repositories/notifications_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart'
    show SellerOrder;
import 'package:book_store_app/app/modules/notifications/controllers/notifications_badge_controller.dart';
import 'package:book_store_app/app/network/notifications_socket_service.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/routes/deep_link_router.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:book_store_app/app/modules/seller/utils/seller_link_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository _repository = NotificationsRepository();
  final SellerOrdersRepository _sellerOrdersRepository = SellerOrdersRepository();
  final NotificationsSocketService _socket = NotificationsSocketService.instance;
  StreamSubscription? _newSub;
  StreamSubscription? _countSub;

  final RxList<NotificationModel> _all = <NotificationModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter.value == 'all') return List.unmodifiable(_all);
    return _all.where((n) => n.filterKey == selectedFilter.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _socket.ensureConnected();
    _newSub = _socket.onNewNotification.listen((json) {
      _all.insert(0, NotificationModel.fromJson(json));
    });
    _countSub = _socket.onUnreadCount.listen((count) => unreadCount.value = count);
  }

  Future<void> fetchNotifications() async {
    // Notifications are a login-only feature — a guest tapping the bell
    // icon gets a clear reason the inbox is empty, not a raw 401.
    if (!await AppPreferences.isLoggedIn()) {
      ToastUtil.showToast('Login to view your notifications');
      return;
    }
    isLoading.value = true;
    final result = await _repository.list();
    _all.assignAll(result.items);
    unreadCount.value = result.unreadCount;
    _syncBadge();
    isLoading.value = false;
  }

  /// Keeps the app-bar bell badge (`NotificationsBadgeController`) in step —
  /// it doesn't otherwise learn about read-state changes made from this
  /// screen, since the backend only pushes `notification:unread-count` on
  /// new notifications, not on markRead/markAllRead.
  void _syncBadge() {
    if (Get.isRegistered<NotificationsBadgeController>()) {
      Get.find<NotificationsBadgeController>().unreadCount.value = unreadCount.value;
    }
  }

  @override
  Future<void> refresh() => fetchNotifications();

  void setFilter(String filter) => selectedFilter.value = filter;

  Future<void> markRead(String id) async {
    final idx = _all.indexWhere((n) => n.id == id);
    if (idx < 0 || _all[idx].isRead) return;
    _all[idx] = _all[idx].copyWith(isRead: true);
    _all.refresh();
    unreadCount.value = (unreadCount.value - 1).clamp(0, 1 << 30);
    _syncBadge();
    await _repository.markRead(id);
  }

  /// Marks the tapped notification read and routes to it. The server's
  /// `data.link` wins when it is a page this app has; otherwise the type
  /// decides, per role (sellers and buyers get different screens for the
  /// same type, e.g. `order_placed`). Unknown types stay on the inbox.
  Future<void> openNotification(NotificationModel notification) async {
    markRead(notification.id);
    final data = notification.data ?? const <String, dynamic>{};
    final isSeller = await AppPreferences.getUserRole() == 'seller';
    if (!isSeller && DeepLinkRouter.open(data['link']?.toString())) return;
    if (isSeller) {
      await _openForSeller(notification.rawType, data, notification);
    } else {
      _openForBuyer(notification.rawType, data);
    }
  }

  void _openForBuyer(String? type, Map<String, dynamic> data) {
    switch (type) {
      case 'order_placed':
      case 'order_cancelled':
      case 'order_shipped':
      case 'order_delivered':
      case 'payment_success':
      case 'payment_failed':
      case 'payment_received':
        final orderId = data['orderId']?.toString();
        Get.toNamed(Routes.myOrdersView,
            arguments: (orderId == null || orderId.isEmpty) ? null : {'orderId': orderId});
        break;
      case 'new_message':
        _openConversation(data);
        break;
      case 'support_reply':
        Get.toNamed(Routes.supportChat);
        break;
      case 'loyalty_points_earned':
      case 'loyalty_tier_upgrade':
        final storeId = data['storeId']?.toString();
        if (storeId != null && storeId.isNotEmpty) {
          Get.toNamed(Routes.loyaltyRewards,
              arguments: {'storeId': storeId, 'storeName': 'Store'});
        }
        break;
      case 'subscription_renewal_reminder':
      case 'subscription_payment_failed':
      case 'subscription_cancelled':
        Get.toNamed(Routes.myMemberships);
        break;
      default:
        break;
    }
  }

  Future<void> _openForSeller(
    String? type,
    Map<String, dynamic> data, [
    NotificationModel? notification,
  ]) async {
    switch (type) {
      case 'order_placed':
      case 'order_cancelled':
        final orderId = data['orderId']?.toString();
        if (orderId != null && orderId.isNotEmpty) {
          await _openSellerOrder(orderId);
        } else {
          Get.toNamed(Routes.sellerOrders);
        }
        break;
      case 'return_requested':
      case 'refund_requested':
        Get.toNamed(Routes.sellerReturns);
        break;
      case 'new_message':
        _openConversation(data);
        break;
      case 'new_follower':
      case 'store_approved':
      case 'store_rejected':
        Get.toNamed(Routes.sellerStoreProfile);
        break;
      case 'low_stock':
      case 'out_of_stock':
      case 'listing_published':
      case 'listing_in_review':
      case 'listing_approved':
        Get.toNamed(Routes.sellerProducts);
        break;
      // Sent back by Edudeen: open the "Needs changes" tab (checklist #11).
      case 'listing_fix_requested':
      case 'listing_rejected':
        Get.toNamed(Routes.sellerProducts, arguments: {'tab': 'rejected'});
        break;
      case 'platform_campaign_live':
        // link = /store/:id/marketing?tab=platform -> Platform Sales.
        Get.toNamed(Routes.sellerPlatformSales);
        break;
      case 'store_deleted':
        await Get.dialog(AlertDialog(
          title: Text(notification?.title.isNotEmpty == true
              ? notification!.title
              : 'Your store was removed'),
          content: notification?.body.isNotEmpty == true
              ? Text(notification!.body)
              : null,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ));
        await AppPreferences.clearStoreId();
        Get.offAllNamed(Routes.sellerStores);
        break;
      case 'payout_update':
      case 'payout_approved':
      case 'payout_rejected':
        Get.toNamed(Routes.sellerFinance);
        break;
      case 'platform_plan_renewal_reminder':
      case 'platform_plan_payment_failed':
      case 'trial_ending':
      case 'trial_ended':
      case 'plan_ended':
        Get.toNamed(Routes.sellerPlatformPlan);
        break;
      case 'support_reply':
        Get.toNamed(Routes.supportChat);
        break;
      default:
        // Unknown type: follow data.link when it maps to a seller screen;
        // otherwise stay on the inbox.
        final route = SellerLinkRouter.routeFor(data['link']?.toString());
        if (route != null) Get.toNamed(route);
        break;
    }
  }

  void _openConversation(Map<String, dynamic> data) {
    final conversationId = data['conversationId']?.toString();
    if (conversationId != null && conversationId.isNotEmpty) {
      Get.toNamed(Routes.chatView, arguments: {'conversationId': conversationId});
    } else {
      Get.toNamed(Routes.messagesView);
    }
  }

  /// Finds the order among the seller's recent orders so the tap lands on
  /// its detail screen (which needs the full [SellerOrder]); falls back to
  /// the orders list.
  Future<void> _openSellerOrder(String orderId) async {
    final storeId = await AppPreferences.getStoreId();
    if (storeId != null && storeId.isNotEmpty) {
      final result = await _sellerOrdersRepository.fetchSellerOrders(
        storeId: storeId,
        page: 1,
        limit: 50,
      );
      for (final json in result.orders) {
        final order = SellerOrder.fromApiJson(json);
        if (order.id == orderId) {
          Get.toNamed(Routes.sellerOrderDetail, arguments: order);
          return;
        }
      }
    }
    Get.toNamed(Routes.sellerOrders);
  }

  Future<void> markAllRead() async {
    for (int i = 0; i < _all.length; i++) {
      _all[i] = _all[i].copyWith(isRead: true);
    }
    _all.refresh();
    unreadCount.value = 0;
    _syncBadge();
    await _repository.markAllRead();
  }

  @override
  void onClose() {
    _newSub?.cancel();
    _countSub?.cancel();
    super.onClose();
  }
}
