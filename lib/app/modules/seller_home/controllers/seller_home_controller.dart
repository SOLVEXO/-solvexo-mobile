import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHomeController extends GetxController {
  final _ordersRepo = SellerOrdersRepository();
  final _messagingRepo = MessagingRepository();

  final RxBool isLoading = true.obs;

  // Stats (still static until a dashboard API is available)
  final RxDouble todayRevenue = 1284.00.obs;
  final RxDouble revenueChange = 12.4.obs;
  final RxInt ordersCount = 38.obs;
  final RxString visitors = '2.1K'.obs;
  final RxDouble conversionRate = 1.78.obs;
  final RxDouble avgOrderValue = 33.79.obs;

  final RxList<SellerOrder> recentOrders = <SellerOrder>[].obs;

  final RxList<String> lowStockItems = <String>[
    'Wall Hanging',
    'Candle',
    'Photo Book',
  ].obs;

  //  replace with real subscription check from API
  final RxBool hasPosSubscription = false.obs;

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
      await Future.wait([_loadRecentOrders(), _loadRecentMessages()]);
    } finally {
      isLoading.value = false;
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
