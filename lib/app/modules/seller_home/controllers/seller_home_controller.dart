import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerMessage {
  final String id;
  final String senderName;
  final String preview;
  final String timeAgo;
  final bool isUnread;

  const SellerMessage({
    required this.id,
    required this.senderName,
    required this.preview,
    required this.timeAgo,
    this.isUnread = false,
  });

  String get initials {
    final parts = senderName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}

class SellerHomeController extends GetxController {
  final _ordersRepo = SellerOrdersRepository();

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

  final RxList<SellerMessage> messages = <SellerMessage>[
    SellerMessage(
      id: '1',
      senderName: 'Sarah M.',
      preview: 'Hi! Does the Math Bundle include answer k...',
      timeAgo: '2m ago',
      isUnread: true,
    ),
    SellerMessage(
      id: '2',
      senderName: 'David R.',
      preview: "My order hasn't arrived yet...",
      timeAgo: '1h ago',
    ),
  ].obs;

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
      await _loadRecentOrders();
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
}
