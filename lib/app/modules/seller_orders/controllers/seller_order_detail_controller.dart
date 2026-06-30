import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerOrderDetailController extends GetxController {
  final _repo = SellerOrdersRepository();

  late final Rx<SellerOrder> order;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    order = (Get.arguments as SellerOrder).obs;
  }

  /// Full network refresh — fetches first 50 orders and finds this one by ID.
  Future<void> refreshOrder() async {
    isLoading.value = true;
    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) return;

      final result = await _repo.fetchSellerOrders(
        storeId: storeId,
        page: 1,
        limit: 50,
      );

      final updated = result.orders
          .map((json) => SellerOrder.fromApiJson(json))
          .cast<SellerOrder?>()
          .firstWhere(
            (o) => o?.id == order.value.id,
            orElse: () => null,
          );

      if (updated != null) {
        order.value = updated;
        // Also keep the list view in sync
        _syncToListController(updated);
      }
    } catch (e) {
      debugPrint('❌ refreshOrder error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cheap sync — reads the updated order from the already-loaded list controller
  /// without a network call (e.g., after status picker sheet closes).
  void syncFromParent() {
    try {
      final parent = Get.find<SellerOrdersController>();
      final updated = parent.findOrder(order.value.id);
      if (updated != null) order.value = updated;
    } catch (_) {}
  }

  void _syncToListController(SellerOrder updated) {
    try {
      Get.find<SellerOrdersController>().syncOrder(updated);
    } catch (_) {}
  }
}
