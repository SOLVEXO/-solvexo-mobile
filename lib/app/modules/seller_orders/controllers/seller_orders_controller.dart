import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum OrderStatus { all, pending, processing, shipped, completed, refunded }

// ── Stats model ───────────────────────────────────────────────────────────────

class SellerOrderStats {
  final int totalOrders;
  final double revenue;
  final int pending;
  final double avgOrder;

  const SellerOrderStats({
    required this.totalOrders,
    required this.revenue,
    required this.pending,
    required this.avgOrder,
  });

  factory SellerOrderStats.fromJson(Map<String, dynamic> json) {
    return SellerOrderStats(
      totalOrders: json['totalOrders'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      pending: json['pending'] as int? ?? 0,
      avgOrder: (json['avgOrder'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const empty =
      SellerOrderStats(totalOrders: 0, revenue: 0, pending: 0, avgOrder: 0);
}

// ── Order item model ──────────────────────────────────────────────────────────

class SellerOrderItem {
  final String productName;
  final int quantity;
  final double price;
  final String type; // 'Physical' | 'Digital'
  final String? image;

  const SellerOrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.type,
    this.image,
  });

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String? ?? 'physical';
    final type =
        rawType[0].toUpperCase() + rawType.substring(1).toLowerCase();
    return SellerOrderItem(
      productName: json['name'] as String? ??
          json['productName'] as String? ??
          json['product'] as String? ??
          '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      type: type,
      image: json['image'] as String?,
    );
  }

  double get totalPrice => price * quantity;
}

// ── Order model ───────────────────────────────────────────────────────────────

class SellerOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final double amount;
  final String date;
  final OrderStatus status;
  final bool isPaid;
  final String paymentType;
  final List<SellerOrderItem> items;

  const SellerOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.amount,
    required this.date,
    required this.status,
    required this.isPaid,
    required this.paymentType,
    required this.items,
  });

  // Derived helpers — based on the first item for fallback display
  String get primaryProductName =>
      items.isNotEmpty ? items.first.productName : '';
  String get primaryType => items.isNotEmpty ? items.first.type : '';
  bool get isCod => paymentType == 'cash_on_delivery';
  bool get isPhysical =>
      items.any((item) => item.type.toLowerCase() == 'physical');
  bool get canMarkPaid =>
      isCod && !isPaid && status != OrderStatus.completed && status != OrderStatus.refunded;
  bool get canUpdateStatus =>
      isPhysical &&
      status != OrderStatus.completed &&
      status != OrderStatus.refunded;

  SellerOrder copyWith({bool? isPaid, OrderStatus? status}) => SellerOrder(
        id: id,
        orderNumber: orderNumber,
        customerName: customerName,
        customerEmail: customerEmail,
        amount: amount,
        date: date,
        status: status ?? this.status,
        isPaid: isPaid ?? this.isPaid,
        paymentType: paymentType,
        items: items,
      );

  factory SellerOrder.fromApiJson(Map<String, dynamic> json) {
    final customer = (json['customer'] as Map<String, dynamic>?) ?? {};

    // Parse items array; fall back to single product flat field
    final rawItems = json['items'] as List<dynamic>?;
    final items = rawItems != null && rawItems.isNotEmpty
        ? rawItems
            .map((e) => SellerOrderItem.fromJson(e as Map<String, dynamic>))
            .toList()
        : <SellerOrderItem>[
            SellerOrderItem(
              productName: json['product'] as String? ?? '',
              quantity: 1,
              price: (json['amount'] as num?)?.toDouble() ?? 0.0,
              type: (() {
                final raw = json['type'] as String? ?? 'physical';
                return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
              })(),
            ),
          ];

    return SellerOrder(
      id: json['orderId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      customerName: customer['name'] as String? ?? '',
      customerEmail: customer['email'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: _formatDate(json['date'] as String? ?? ''),
      status: _parseStatus(json['status'] as String? ?? ''),
      isPaid: json['isPaid'] as bool? ?? false,
      paymentType: json['paymentType'] as String? ?? '',
      items: items,
    );
  }

  static OrderStatus _parseStatus(String s) {
    switch (s) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'completed':
        return OrderStatus.completed;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  static String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final day = DateTime(dt.year, dt.month, dt.day);
      final time = DateFormat('h:mm a').format(dt);
      if (day == today) return 'Today $time';
      if (day == today.subtract(const Duration(days: 1))) {
        return 'Yesterday $time';
      }
      return DateFormat('MMM d, y · h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class SellerOrdersController extends GetxController {
  final _repo = SellerOrdersRepository();

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<OrderStatus> selectedFilter = OrderStatus.all.obs;
  final Rx<SellerOrderStats> stats = SellerOrderStats.empty.obs;
  final RxInt totalOrders = 0.obs;

  final RxList<SellerOrder> _allOrders = <SellerOrder>[].obs;
  final RxSet<String> _markingPaidIds = <String>{}.obs;
  final RxSet<String> _updatingStatusIds = <String>{}.obs;

  int _page = 1;
  bool _hasMore = false;
  static const int _pageSize = 20;

  // ── Computed ──────────────────────────────────────────────────────────────

  List<SellerOrder> get filteredOrders {
    if (selectedFilter.value == OrderStatus.all) {
      return List<SellerOrder>.from(_allOrders);
    }
    return _allOrders
        .where((o) => o.status == selectedFilter.value)
        .toList();
  }

  bool get hasMore => _hasMore;

  int countFor(OrderStatus status) {
    if (status == OrderStatus.all) return totalOrders.value;
    return _allOrders.where((o) => o.status == status).length;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void setFilter(OrderStatus status) => selectedFilter.value = status;

  SellerOrder? findOrder(String id) {
    try {
      return _allOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  void syncOrder(SellerOrder updated) {
    final idx = _allOrders.indexWhere((o) => o.id == updated.id);
    if (idx != -1) _allOrders[idx] = updated;
  }

  bool isMarkingPaid(String orderId) => _markingPaidIds.contains(orderId);
  bool isUpdatingStatus(String orderId) => _updatingStatusIds.contains(orderId);

  Future<bool> updateOrderStatus(
    String orderId,
    String newStatus, {
    Map<String, String>? tracking,
  }) async {
    if (_updatingStatusIds.contains(orderId)) return false;
    _updatingStatusIds.add(orderId);
    try {
      final storeId = await AppPreferences.getStoreId() ?? '';
      final success = await _repo.updateOrderStatus(
        orderId: orderId,
        storeId: storeId,
        status: newStatus,
        tracking: tracking,
      );
      if (success) {
        final idx = _allOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          final parsed = OrderStatus.values.firstWhere(
            (s) => s.name == newStatus,
            orElse: () => OrderStatus.pending,
          );
          _allOrders[idx] = _allOrders[idx].copyWith(status: parsed);
        }
        ToastUtil.showToast('Order status updated');
      }
      return success;
    } finally {
      _updatingStatusIds.remove(orderId);
    }
  }

  Future<bool> markOrderPaid(String orderId) async {
    if (_markingPaidIds.contains(orderId)) return false;
    _markingPaidIds.add(orderId);
    try {
      final success = await _repo.markOrderPaid(orderId);
      if (success) {
        final idx = _allOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) {
          _allOrders[idx] = _allOrders[idx].copyWith(
            isPaid: true,
            status: OrderStatus.completed,
          );
        }
        ToastUtil.showToast('Order marked as paid');
      }
      return success;
    } finally {
      _markingPaidIds.remove(orderId);
    }
  }

  Future<void> refreshData() async {
    _page = 1;
    _hasMore = false;
    _allOrders.clear();
    isLoading.value = true;
    await _load(isRefresh: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value) return;
    await _load(page: _page + 1);
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> _load({int page = 1, bool isRefresh = false}) async {
    if (page == 1 && !isRefresh) {
      isLoading.value = true;
    } else if (page > 1) {
      isLoadingMore.value = true;
    }

    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) {
        debugPrint('⚠️ SellerOrdersController: no storeId in prefs');
        return;
      }

      final result = await _repo.fetchSellerOrders(
        storeId: storeId,
        page: page,
        limit: _pageSize,
      );

      final parsed = result.orders
          .map((json) => SellerOrder.fromApiJson(json))
          .toList();

      if (page == 1) {
        _allOrders.assignAll(parsed);
        if (result.stats.isNotEmpty) {
          stats.value = SellerOrderStats.fromJson(result.stats);
        }
      } else {
        _allOrders.addAll(parsed);
      }

      totalOrders.value = result.totalOrders;
      _hasMore = result.hasMore;
      _page = page;

      debugPrint(
          '✅ Loaded ${parsed.length} orders (page $page, total ${result.totalOrders})');
    } catch (e) {
      debugPrint('❌ _load error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _load();
  }
}
