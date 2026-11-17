
import 'package:book_store_app/core/base/base_controller.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/services/digital_download_service.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_timeline.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MyOrdersController extends BaseController {
  MyOrdersController({OrderRepository? orderRepository})
    : _orderRepository = orderRepository ?? OrderRepository();

  RxInt selectedTab = 0.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final Rx<OrderDeliveryStatus> currentStatus = OrderDeliveryStatus.deliver.obs;
  int get currentStep =>
      OrderDeliveryStatus.values.indexOf(currentStatus.value);

  final OrderRepository _orderRepository;

  @override
  RxBool isLoading = false.obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;

  // ── Digital product delivery ──────────────────────────────────────────────
  /// Shared with the Library tab.
  final DigitalDownloadService _downloads = DigitalDownloadService();

  bool isDownloading(String itemId) => _downloads.isBusy(itemId);

  /// Fetches signed links for a purchased digital item, then downloads its
  /// single file or lets the buyer pick one.
  Future<void> downloadDigitalItem(String orderId, OrderItem item) =>
      _downloads.download(
        busyKey: item.itemId,
        orderId: orderId,
        productId: item.productId,
      );

  @override
  void onInit() {
    fetchOrders();
    super.onInit();
  }

  /// Fetch orders from API
  Future<void> fetchOrders() async {
    // Updates the inherited `loginUser` flag the view keys off of — guests
    // never hit the (login-only) endpoint in the first place.
    if (!await isUserLogin()) {
      orders.clear();
      return;
    }
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
  Future<void> cancelOrder(
    String orderId, {
    String reason = 'Cancelled by customer',
  }) async {
    try {
      debugPrint('🔄 Cancelling order: $orderId');

      final success = await _orderRepository.cancelOrder(
        orderId,
        reason: reason,
      );

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

  bool _matchesTab(OrderModel e, int tab) {
    switch (tab) {
      case 1:
        return e.orderStatus == 'pending';
      case 2:
        return e.orderStatus == 'processing';
      case 3:
        return e.orderStatus == 'shipped' || e.orderStatus == 'partially_shipped';
      case 4:
        return e.orderStatus == 'completed';
      case 5:
        return e.orderStatus == 'cancelled';
      default:
        return true;
    }
  }

  /// Filter orders by tab + search query
  List<OrderModel> get filteredOrders => orders
      .where((e) => _matchesTab(e, selectedTab.value) && e.matchesQuery(searchQuery.value))
      .toList();

  final tabs = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Completed',
    'Cancelled',
  ];

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Count for a tab index, ignoring the current search query — shown as a
  /// badge on each filter chip so buyers can see where their orders are
  /// before tapping in.
  int tabCount(int tab) => orders.where((e) => _matchesTab(e, tab)).length;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
