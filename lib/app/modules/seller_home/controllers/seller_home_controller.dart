import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_analytics_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHomeController extends GetxController {
  final _ordersRepo = SellerOrdersRepository();
  final _messagingRepo = MessagingRepository();
  final _analyticsRepo = SellerAnalyticsRepository();
  final _productRepo = SellerProductRepository();

  final RxBool isLoading = true.obs;

  // Today's Revenue card — real data from `api/seller/analytics/today`.
  // No "visitors"/"conversion rate" fields — the backend has no storefront
  // visit-tracking to compute them from, so those stat cells are hidden
  // rather than showing invented numbers (see SellerStatusCard).
  final RxDouble todayRevenue = 0.0.obs;
  final Rx<double?> revenueChange = Rx<double?>(null);
  final RxInt ordersCount = 0.obs;
  final RxDouble avgOrderValue = 0.0.obs;

  final RxList<SellerOrder> recentOrders = <SellerOrder>[].obs;

  // Low stock alert — real data from `api/inventory/low-stock-summary`.
  final RxList<String> lowStockItems = <String>[].obs;

  // POS access is entitlement-based in the merged platform-plans system —
  // every plan includes at least one POS location, so there's no paywall
  // gate anymore; "Open POS" navigates straight to POS management.

  final RxList<ConversationModel> recentConversations = <ConversationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        _loadTodaySummary(),
        _loadRecentOrders(),
        _loadRecentMessages(),
        _loadLowStock(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTodaySummary() async {
    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) return;
      final summary = await _analyticsRepo.getTodaySummary(storeId);
      todayRevenue.value = summary.revenue;
      revenueChange.value = summary.revenueChangePercent;
      ordersCount.value = summary.ordersCount;
      avgOrderValue.value = summary.avgOrderValue;
    } catch (e) {
      debugPrint('❌ _loadTodaySummary error: $e');
    }
  }

  Future<void> _loadLowStock() async {
    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) return;
      final result = await _productRepo.fetchLowStockSummary(storeId: storeId);
      lowStockItems.assignAll(
        result.items.map((item) => item['name'] as String? ?? '').where((name) => name.isNotEmpty),
      );
    } catch (e) {
      debugPrint('❌ _loadLowStock error: $e');
    }
  }

  Future<void> _loadRecentOrders() async {
    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) return;
      final result = await _ordersRepo.fetchSellerOrders(
        storeId: storeId,
        page: 1,
        limit: 5,
      );
      recentOrders.assignAll(
        result.orders.map((json) => SellerOrder.fromApiJson(json)).toList(),
      );
    } catch (e) {
      debugPrint('❌ _loadRecentOrders error: $e');
    }
  }

  Future<void> _loadRecentMessages() async {
    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) return;
      final result = await _messagingRepo.getConversations(
        page: 1,
        limit: 3,
        storeId: storeId,
      );
      recentConversations.assignAll(result.conversations);
    } catch (e) {
      debugPrint('❌ _loadRecentMessages error: $e');
    }
  }
}
