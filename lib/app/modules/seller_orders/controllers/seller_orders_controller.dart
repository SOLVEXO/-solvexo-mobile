import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum OrderStatus { all, pending, processing, shipped, delivered, completed, cancelled, refunded }

/// Orders tabs (docs Part B 6.5) = the API's `tab` values.
enum OrdersTab {
  needsAction('needs_action', 'Needs action'),
  shipped('shipped', 'Shipped'),
  delivered('delivered', 'Delivered'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled'),
  all('all', 'All');

  const OrdersTab(this.api, this.label);
  final String api;
  final String label;
}

/// Ship-by badge (docs Part B 2.4 / 6.5: ship within 48 h of payment).
enum ShipByLevel { normal, soon, overdue }

ShipByLevel shipByLevel(DateTime due, DateTime now) {
  final left = due.difference(now);
  if (left.isNegative) return ShipByLevel.overdue;
  if (left < const Duration(hours: 12)) return ShipByLevel.soon;
  return ShipByLevel.normal;
}

String shipByLabel(DateTime due, DateTime now) {
  final left = due.difference(now);
  if (left.isNegative) {
    final h = -left.inHours;
    return h >= 24 ? 'Ship overdue ${h ~/ 24}d' : 'Ship overdue ${h < 1 ? 1 : h}h';
  }
  final h = left.inHours;
  return h >= 24 ? 'Ship in ${h ~/ 24}d ${h % 24}h' : 'Ship in ${h < 1 ? 1 : h}h';
}

/// GET seller-free-claims row ("Availed" free digital items, excluded from
/// revenue). The test store had none, so keys are read defensively.
class FreeClaim {
  const FreeClaim({
    required this.buyerName,
    required this.productName,
    required this.orderNumber,
    this.date,
  });

  final String buyerName;
  final String productName;
  final String orderNumber;
  final DateTime? date;

  factory FreeClaim.fromJson(Map<String, dynamic> j) {
    final buyer = j['buyer'] is Map ? j['buyer'] as Map : (j['customer'] is Map ? j['customer'] as Map : const {});
    final product = j['product'] is Map ? j['product'] as Map : const {};
    return FreeClaim(
      buyerName: '${buyer['name'] ?? j['buyerName'] ?? ''}',
      productName: '${j['productName'] ?? product['name'] ?? (j['product'] is String ? j['product'] : '') ?? ''}',
      orderNumber: '${j['orderNumber'] ?? ''}',
      date: DateTime.tryParse('${j['date'] ?? j['claimedAt'] ?? j['createdAt'] ?? ''}')?.toLocal(),
    );
  }
}

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

// ── Shipping address model ───────────────────────────────────────────────────

class SellerOrderAddress {
  final String recipientName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;

  const SellerOrderAddress({
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory SellerOrderAddress.fromJson(Map<String, dynamic> json) {
    return SellerOrderAddress(
      recipientName: json['recipientName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
    );
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      state,
      zipCode,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }
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

  /// 'seller' or 'platform' (Edudeen ships; the seller can't change status,
  /// tracking or payment). Missing means seller-fulfilled.
  final String fulfillmentMode;

  /// COD per package (docs Part B 2.3): who collects the cash, 'seller' or
  /// 'platform' (Edudeen courier). Null when the row does not say.
  final String? codCollector;

  /// Order-level payment status; 'partially_paid' when only some packages
  /// of a multi-seller COD order are confirmed paid.
  final String paymentStatus;
  final List<SellerOrderItem> items;
  final SellerOrderAddress? shippingAddress;

  /// Server ship-by deadline when sent; else paidAt + 48 h for physical
  /// packages (display only).
  final DateTime? shipBy;
  final DateTime? paidAt;

  /// Buyer's cancel reason (cancelled-by-buyer), gift note, real buyer phone.
  final String? cancelReason;
  final String? giftNote;
  final String? buyerPhone;

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
    this.fulfillmentMode = 'seller',
    this.codCollector,
    this.paymentStatus = '',
    required this.items,
    this.shippingAddress,
    this.shipBy,
    this.paidAt,
    this.cancelReason,
    this.giftNote,
    this.buyerPhone,
  });

  /// Only while the package still has to go out.
  DateTime? get shipByDeadline {
    if (!isPhysical || isPlatformFulfilled) return null;
    if (status != OrderStatus.pending && status != OrderStatus.processing) return null;
    return shipBy ?? paidAt?.add(const Duration(hours: 48));
  }

  // Derived helpers — based on the first item for fallback display
  String get primaryProductName =>
      items.isNotEmpty ? items.first.productName : '';
  String get primaryType => items.isNotEmpty ? items.first.type : '';
  bool get isCod => paymentType == 'cash_on_delivery';
  bool get isPlatformFulfilled => fulfillmentMode == 'platform';
  bool get isPhysical =>
      items.any((item) => item.type.toLowerCase() == 'physical');
  /// Who collects this package's cash. Rows without `codCollector` follow
  /// the fulfilment: Edudeen collects only when its courier delivers
  /// (docs Part B 2.3; couriers are off today, so normally the seller).
  String get effectiveCodCollector =>
      codCollector ?? (isPlatformFulfilled ? 'platform' : 'seller');

  /// "Mark paid" only for seller-collected COD (docs Part B 2.3); Edudeen
  /// confirms platform-collected packages.
  bool get canMarkPaid =>
      isCod &&
      !isPaid &&
      effectiveCodCollector == 'seller' &&
      status != OrderStatus.completed &&
      status != OrderStatus.refunded;

  bool get isPartiallyPaid => paymentStatus == 'partially_paid';

  /// Payment line for this package. The package's own isPaid decides; the
  /// order-level 'partially_paid' is shown as context.
  String get paymentLabel {
    if (isPaid) return 'Paid';
    if (isPartiallyPaid) return 'Unpaid (order partly paid)';
    if (isCod && effectiveCodCollector == 'platform') return 'Unpaid - Edudeen collects';
    return 'Unpaid';
  }
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
        fulfillmentMode: fulfillmentMode,
        codCollector: codCollector,
        paymentStatus: paymentStatus,
        items: items,
        shippingAddress: shippingAddress,
        shipBy: shipBy,
        paidAt: paidAt,
        cancelReason: cancelReason,
        giftNote: giftNote,
        buyerPhone: buyerPhone,
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

    final rawAddress = json['shippingAddress'] as Map<String, dynamic>?;

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
      fulfillmentMode: json['fulfillmentMode'] as String? ?? 'seller',
      codCollector: json['codCollector'] as String?,
      paymentStatus: json['paymentStatus'] as String? ?? '',
      items: items,
      shippingAddress:
          rawAddress != null ? SellerOrderAddress.fromJson(rawAddress) : null,
      shipBy: _date(json['shipBy'] ?? json['shipByAt'] ?? json['dispatchBy']),
      paidAt: _date(json['paidAt']),
      cancelReason: _str(json['cancelReason'] ?? json['cancellationReason']),
      giftNote: _str(json['giftMessage'] ?? json['giftNote']),
      buyerPhone: _str(customer['phone'] ?? rawAddress?['phone'] ?? json['buyerPhone']),
    );
  }

  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();
  static String? _str(dynamic v) {
    if (v == null || v is Map || v is List) return null;
    final s = '$v'.trim();
    return s.isEmpty ? null : s;
  }

  static OrderStatus _parseStatus(String s) {
    switch (s) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
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
  final RxBool loadFailed = false.obs;
  final Rx<OrdersTab> selectedTab = OrdersTab.needsAction.obs;

  /// Server counts per tab (+ 'toShip', 'overdue').
  final RxMap<String, int> counts = <String, int>{}.obs;
  int countForTab(OrdersTab t) => counts[t.api] ?? 0;

  void setTab(OrdersTab t) {
    if (selectedTab.value == t) return;
    selectedTab.value = t;
    refreshData();
  }

  // ── Free claims card ──────────────────────────────────────────────────────
  final RxList<FreeClaim> freeClaims = <FreeClaim>[].obs;
  final RxInt freeClaimsTotal = 0.obs;
  final RxBool freeClaimsLoading = false.obs;
  final RxBool freeClaimsFailed = false.obs;

  Future<void> loadFreeClaims() async {
    freeClaimsLoading.value = true;
    freeClaimsFailed.value = false;
    try {
      final storeId = await AppPreferences.getStoreId() ?? '';
      final r = await _repo.getFreeClaims(storeId);
      freeClaims.assignAll(r.claims);
      freeClaimsTotal.value = r.total;
    } catch (_) {
      freeClaimsFailed.value = true;
    } finally {
      freeClaimsLoading.value = false;
    }
  }
  final Rx<SellerOrderStats> stats = SellerOrderStats.empty.obs;
  final RxInt totalOrders = 0.obs;

  final RxList<SellerOrder> _allOrders = <SellerOrder>[].obs;
  final RxSet<String> _markingPaidIds = <String>{}.obs;
  final RxSet<String> _updatingStatusIds = <String>{}.obs;

  int _page = 1;
  bool _hasMore = false;
  static const int _pageSize = 20;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Rows of the selected tab (filtered by the server).
  List<SellerOrder> get filteredOrders => List<SellerOrder>.from(_allOrders);

  bool get hasMore => _hasMore;

  // ── Actions ───────────────────────────────────────────────────────────────

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

  /// Sub-orders the API refused to let this seller manage (403): they are
  /// fulfilled by Edudeen, so the status / tracking / mark-paid actions are
  /// hidden. Rows carry `fulfillmentMode`, so this normally knows up front; the
  /// 403 is only a fallback for rows that don't.
  final RxSet<String> platformFulfilledIds = <String>{}.obs;
  bool isPlatformFulfilled(String orderId) =>
      platformFulfilledIds.contains(orderId) ||
      (_allOrders.firstWhereOrNull((o) => o.id == orderId)?.isPlatformFulfilled ??
          false);

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
        onForbidden: () => platformFulfilledIds.add(orderId),
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
      final storeId = await AppPreferences.getStoreId() ?? '';
      final success = await _repo.markOrderPaid(
        orderId,
        storeId: storeId,
        onForbidden: () => platformFulfilledIds.add(orderId),
      );
      if (success) {
        // Only the payment changes; the status stays the server's own.
        final idx = _allOrders.indexWhere((o) => o.id == orderId);
        if (idx != -1) _allOrders[idx] = _allOrders[idx].copyWith(isPaid: true);
        ToastUtil.showToast('Package marked as paid');
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
        tab: selectedTab.value.api,
      );
      if (result.failed && page == 1) {
        loadFailed.value = true;
        _allOrders.clear();
        return;
      }
      loadFailed.value = false;
      if (result.counts.isNotEmpty) counts.assignAll(result.counts);

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
    loadFreeClaims();
  }
}
