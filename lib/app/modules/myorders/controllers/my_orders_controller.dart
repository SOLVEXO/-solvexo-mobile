import 'package:book_store_app/core/base/base_controller.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_timeline.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MyOrdersController extends BaseController {
  RxInt selectedTab = 0.obs;
  final Rx<OrderDeliveryStatus> currentStatus = OrderDeliveryStatus.deliver.obs;
  int get currentStep =>
      OrderDeliveryStatus.values.indexOf(currentStatus.value);

  final OrderRepository _orderRepository = OrderRepository();

  @override
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
  Future<void> refreshOrders() => fetchOrders();

  /// Cancel order
  Future<void> cancelOrder(String orderId, {String reason = 'Cancelled by customer'}) async {
    try {
      debugPrint('🔄 Cancelling order: $orderId');

      final success = await _orderRepository.cancelOrder(orderId, reason: reason);

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

  /// Confirms with the buyer before cancelling — the backend requires a
  /// non-empty `reason`, so a default is sent since the app doesn't yet
  /// collect a specific one from the user.
  void confirmCancel(BuildContext context, String orderId) {
    CustomConfirmDialog.show(
      context,
      title: 'Cancel this order?',
      message: 'This can\'t be undone. The seller will be notified.',
      confirmLabel: 'Cancel Order',
      confirmColor: AppColors.red,
      onConfirm: () => cancelOrder(orderId),
    );
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

  bool orderCanCancel(OrderModel order) => order.canCancel;
  bool orderIsCompleted(OrderModel order) => order.isCompleted;

  void updateStatus(OrderDeliveryStatus status) {
    currentStatus.value = status;
  }

  /// Filter orders by tab
  List<OrderModel> get filteredOrders {
    switch (selectedTab.value) {
      case 1:
        return orders.where((e) => e.orderStatus == 'pending').toList();
      case 2:
        return orders.where((e) => e.orderStatus == 'processing').toList();
      case 3:
        return orders
            .where((e) =>
                e.orderStatus == 'shipped' ||
                e.orderStatus == 'partially_shipped')
            .toList();
      case 4:
        return orders.where((e) => e.orderStatus == 'completed').toList();
      case 5:
        return orders.where((e) => e.orderStatus == 'cancelled').toList();
      default:
        return orders;
    }
  }

  final tabs = ['All', 'Pending', 'Processing', 'Shipped', 'Completed', 'Cancelled'];

  void changeTab(int index) {
    selectedTab.value = index;
  }

  /// Get order count by status
  int getOrderCountByStatus(String status) {
    if (status == 'all') return orders.length;
    return orders.where((e) => e.orderStatus == status).toList().length;
  }
}
