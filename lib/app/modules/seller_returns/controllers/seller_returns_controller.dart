import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum ReturnFilter { all, requested, approved, rejected }

extension ReturnFilterApi on ReturnFilter {
  String? get apiValue => this == ReturnFilter.all ? null : name;
}

enum ReturnStatus { requested, approved, rejected }

// ── Stats model ───────────────────────────────────────────────────────────────

class SellerReturnStats {
  final int openRequests;
  final String returnRate;
  final double totalRefunded;

  const SellerReturnStats({
    required this.openRequests,
    required this.returnRate,
    required this.totalRefunded,
  });

  factory SellerReturnStats.fromJson(Map<String, dynamic> json) {
    return SellerReturnStats(
      openRequests: json['openRequests'] as int? ?? 0,
      returnRate: json['returnRate'] as String? ?? '0%',
      totalRefunded: (json['totalRefunded'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const empty =
      SellerReturnStats(openRequests: 0, returnRate: '0%', totalRefunded: 0);
}

// ── Return item model ─────────────────────────────────────────────────────────

class SellerReturnItem {
  final String orderId;
  final String orderNumber;
  final String itemId;
  final String storeId;
  final String customerName;
  final String? customerEmail;
  final String productName;
  final String? productImage;
  final String returnReason;
  final double amount;
  final double refundedAmount;
  final ReturnStatus returnStatus;
  final String? returnRejectReason;
  final String returnRequestedAt;

  const SellerReturnItem({
    required this.orderId,
    required this.orderNumber,
    required this.itemId,
    required this.storeId,
    required this.customerName,
    this.customerEmail,
    required this.productName,
    this.productImage,
    required this.returnReason,
    required this.amount,
    required this.refundedAmount,
    required this.returnStatus,
    this.returnRejectReason,
    required this.returnRequestedAt,
  });

  SellerReturnItem copyWith({
    ReturnStatus? returnStatus,
    String? returnRejectReason,
    double? refundedAmount,
  }) => SellerReturnItem(
        orderId: orderId,
        orderNumber: orderNumber,
        itemId: itemId,
        storeId: storeId,
        customerName: customerName,
        customerEmail: customerEmail,
        productName: productName,
        productImage: productImage,
        returnReason: returnReason,
        amount: amount,
        refundedAmount: refundedAmount ?? this.refundedAmount,
        returnStatus: returnStatus ?? this.returnStatus,
        returnRejectReason: returnRejectReason ?? this.returnRejectReason,
        returnRequestedAt: returnRequestedAt,
      );

  factory SellerReturnItem.fromJson(Map<String, dynamic> json) {
    final customer = (json['customer'] as Map<String, dynamic>?) ?? {};
    return SellerReturnItem(
      orderId: json['orderId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      customerName: customer['name'] as String? ?? 'Unknown',
      customerEmail: customer['email'] as String?,
      productName: json['productName'] as String? ?? '',
      productImage: json['productImage'] as String?,
      returnReason: json['returnReason'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      refundedAmount: (json['refundedAmount'] as num?)?.toDouble() ?? 0.0,
      returnStatus: _parseStatus(json['returnStatus'] as String?),
      returnRejectReason: json['returnRejectReason'] as String?,
      returnRequestedAt: _formatDate(json['returnRequestedAt'] as String?),
    );
  }

  static ReturnStatus _parseStatus(String? s) {
    switch (s) {
      case 'approved':
        return ReturnStatus.approved;
      case 'rejected':
        return ReturnStatus.rejected;
      default:
        return ReturnStatus.requested;
    }
  }

  static String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, y · h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class SellerReturnsController extends GetxController {
  final _repo = SellerOrdersRepository();

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<ReturnFilter> selectedFilter = ReturnFilter.all.obs;
  final Rx<SellerReturnStats> stats = SellerReturnStats.empty.obs;
  final RxList<SellerReturnItem> returns = <SellerReturnItem>[].obs;
  final RxSet<String> _processingItemIds = <String>{}.obs;

  String? _storeId;
  int _page = 1;
  bool _hasMore = false;

  bool get hasMore => _hasMore;

  bool isProcessing(String itemId) => _processingItemIds.contains(itemId);

  void setFilter(ReturnFilter filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    refreshData();
  }

  Future<void> refreshData() async {
    _page = 1;
    _hasMore = false;
    isLoading.value = true;
    await _load(isRefresh: true);
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value) return;
    await _load(page: _page + 1);
  }

  Future<void> _load({int page = 1, bool isRefresh = false}) async {
    if (page == 1 && !isRefresh) {
      isLoading.value = true;
    } else if (page > 1) {
      isLoadingMore.value = true;
    }

    try {
      _storeId ??= await AppPreferences.getStoreId();
      final storeId = _storeId;
      if (storeId == null || storeId.isEmpty) {
        debugPrint('⚠️ SellerReturnsController: no storeId in prefs');
        return;
      }

      final result = await _repo.fetchSellerReturns(
        storeId: storeId,
        status: selectedFilter.value.apiValue,
        page: page,
      );

      final parsed =
          result.returns.map((json) => SellerReturnItem.fromJson(json)).toList();

      if (page == 1) {
        returns.assignAll(parsed);
        if (result.stats.isNotEmpty) {
          stats.value = SellerReturnStats.fromJson(result.stats);
        }
      } else {
        returns.addAll(parsed);
      }

      _hasMore = result.hasMore;
      _page = page;
    } catch (e) {
      debugPrint('❌ SellerReturnsController._load error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> approve(SellerReturnItem item) => _act(item, action: 'approve');

  Future<void> reject(SellerReturnItem item, String reason) =>
      _act(item, action: 'reject', rejectReason: reason);

  Future<void> _act(
    SellerReturnItem item, {
    required String action,
    String? rejectReason,
  }) async {
    if (_processingItemIds.contains(item.itemId)) return;
    _processingItemIds.add(item.itemId);
    try {
      final success = await _repo.returnAction(
        orderId: item.orderId,
        storeId: item.storeId,
        itemIds: [item.itemId],
        action: action,
        rejectReason: rejectReason,
      );

      if (success) {
        final idx = returns.indexWhere((r) => r.itemId == item.itemId);
        if (idx != -1) {
          returns[idx] = returns[idx].copyWith(
            returnStatus:
                action == 'approve' ? ReturnStatus.approved : ReturnStatus.rejected,
            returnRejectReason: rejectReason,
            refundedAmount: action == 'approve' ? item.amount : null,
          );
        }
        ToastUtil.showToast(
          action == 'approve' ? 'Return approved' : 'Return rejected',
        );
      }
    } finally {
      _processingItemIds.remove(item.itemId);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }
}
