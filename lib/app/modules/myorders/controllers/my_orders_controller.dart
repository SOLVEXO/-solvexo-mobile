import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_timeline.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MyOrdersController extends GetxController {
  RxInt selectedTab = 0.obs;
  final Rx<OrderDeliveryStatus> currentStatus = OrderDeliveryStatus.deliver.obs;
  int get currentStep =>
      OrderDeliveryStatus.values.indexOf(currentStatus.value);

  final OrderRepository _orderRepository = OrderRepository();

  RxBool isLoading = false.obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  /// Fetch orders from API
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Fetching orders...');

      final fetchedOrders = await _orderRepository.getMyOrders();
      orders.value = fetchedOrders;

      debugPrint('✅ Fetched ${orders.length} orders');

      if (orders.isEmpty) {
        debugPrint('ℹ️ No orders found');
      }
    } catch (e) {
      debugPrint('❌ Fetch orders error: $e');
      ToastUtil.showToast('Failed to load orders!');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh orders (pull to refresh)
  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      debugPrint('🔄 Cancelling order: $orderId');

      final success = await _orderRepository.cancelOrder(orderId);

      if (success) {
        ToastUtil.showToast('Order cancelled successfully');
        await fetchOrders(); // Refresh list
      } else {
        ToastUtil.showToast('Failed to cancel order');
      }
    } catch (e) {
      debugPrint('❌ Cancel order error: $e');
      ToastUtil.showToast('Error cancelling order');
    }
  }

  final List<OrderTimeline> timeline = [
    OrderTimeline(
      status: OrderDeliveryStatus.process,
      title: "Package picked up",
      description: "Your package has left the sorting centre",
    ),
    OrderTimeline(
      status: OrderDeliveryStatus.deliver,
      title: "Deliver",
      description: "Preparing for delivery",
    ),
    OrderTimeline(
      status: OrderDeliveryStatus.inTransit,
      title: "Arrived at delivery hub",
      description: "Package arrived at logistics hub",
    ),
    OrderTimeline(
      status: OrderDeliveryStatus.delivered,
      title: "Delivered",
      description: "Your package has been delivered",
    ),
  ];

  bool get canCancel => currentStatus.value == OrderDeliveryStatus.process;
  bool get canRefund => currentStatus.value != OrderDeliveryStatus.delivered;
  bool get canReview => currentStatus.value == OrderDeliveryStatus.delivered;

  void updateStatus(OrderDeliveryStatus status) {
    currentStatus.value = status;
  }

  /// Filter orders by tab
  List<OrderModel> get filteredOrders {
    switch (selectedTab.value) {
      case 1:
        return orders.where((e) => e.orderStatus == "pending").toList();
      case 2:
        return orders.where((e) => e.orderStatus == "processing").toList();
      case 3:
        return orders.where((e) => e.orderStatus == "shipped").toList();
      case 4:
        return orders.where((e) => e.orderStatus == "delivered").toList();
      default:
        return orders;
    }
  }

  final tabs = ["All", "Pending", "Processing", "Shipped", "Delivered"];

  void changeTab(int index) {
    selectedTab.value = index;
  }

  /// Get order count by status
  int getOrderCountByStatus(String status) {
    if (status == 'all') return orders.length;
    return orders.where((e) => e.orderStatus == status).toList().length;
  }
}
