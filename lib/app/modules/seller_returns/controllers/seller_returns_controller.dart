import 'package:book_store_app/app/data/repositories/refund_request_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/modules/seller_returns/models/seller_return_item.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:get/get.dart';

export 'package:book_store_app/app/modules/seller_returns/models/seller_return_item.dart';

/// Display filter over the loaded rows (the merged endpoint is read whole).
enum ReturnFilter { open, approved, rejected, all }

/// Returns & refunds (docs Part B 6.6; checklist #8): ONE list from
/// seller-returns-all, keyed by `source` + `requestId` (backend 5adba44).
/// source=return -> PUT return-action / PATCH return-follow-up on the order;
/// source=refund -> PATCH refund-request/:requestId/approve|reject|follow-up.
/// Follow-up buttons follow the detail route's server `actions`.
class SellerReturnsController extends GetxController {
  SellerReturnsController({
    SellerOrdersRepository? orders,
    RefundRequestRepository? refunds,
  })  : _orders = orders ?? SellerOrdersRepository(),
        _refunds = refunds ?? RefundRequestRepository();

  final SellerOrdersRepository _orders;
  final RefundRequestRepository _refunds;

  static const minRejectChars = 10;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool loadFailed = false.obs;
  final Rx<ReturnFilter> selectedFilter = ReturnFilter.open.obs;
  final RxList<SellerReturnItem> items = <SellerReturnItem>[].obs;
  final Rx<SellerReturnStats> stats = SellerReturnStats.empty.obs;
  final RxSet<String> _busy = <String>{}.obs;

  String? _storeId;
  int _page = 1;
  int _totalPages = 1;

  bool get hasMore => _page < _totalPages;
  bool isProcessing(SellerReturnItem i) => _busy.contains(_key(i));
  String _key(SellerReturnItem i) => '${i.source}:${i.requestId}';

  /// Detail per row (loaded on demand for the Details sheet).
  final RxMap<String, SellerReturnDetail> details = <String, SellerReturnDetail>{}.obs;
  final RxSet<String> detailFailed = <String>{}.obs;

  Future<void> loadDetail(SellerReturnItem i) async {
    final k = _key(i);
    detailFailed.remove(k);
    try {
      _storeId ??= await AppPreferences.getStoreId();
      details[k] = await _orders.getReturnDetail(_storeId ?? '', i.source, i.requestId);
    } catch (_) {
      detailFailed.add(k);
    }
  }

  SellerReturnDetail? detailFor(SellerReturnItem i) => details[_key(i)];
  bool detailLoadFailed(SellerReturnItem i) => detailFailed.contains(_key(i));

  List<SellerReturnItem> get filtered => switch (selectedFilter.value) {
        ReturnFilter.open => items.where((i) => i.isOpen).toList(),
        ReturnFilter.approved => items.where((i) => i.isApproved).toList(),
        ReturnFilter.rejected => items.where((i) => i.isRejected).toList(),
        ReturnFilter.all => items.toList(),
      };

  int countFor(ReturnFilter f) => switch (f) {
        ReturnFilter.open => items.where((i) => i.isOpen).length,
        ReturnFilter.approved => items.where((i) => i.isApproved).length,
        ReturnFilter.rejected => items.where((i) => i.isRejected).length,
        ReturnFilter.all => items.length,
      };

  void setFilter(ReturnFilter f) => selectedFilter.value = f;

  /// Same rule as the API (400 under 10 characters).
  static String? validateRejectReason(String text) => text.trim().length < minRejectChars
      ? 'Please explain in at least $minRejectChars characters (the buyer will see it).'
      : null;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() => _load(page: 1);

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value) return;
    await _load(page: _page + 1);
  }

  Future<void> _load({required int page}) async {
    if (page == 1) {
      isLoading.value = true;
      loadFailed.value = false;
    } else {
      isLoadingMore.value = true;
    }
    try {
      _storeId ??= await AppPreferences.getStoreId();
      final storeId = _storeId;
      if (storeId == null || storeId.isEmpty) {
        loadFailed.value = true;
        return;
      }
      final r = await _orders.getReturnsAll(storeId, page: page);
      if (page == 1) {
        items.assignAll(r.items);
        stats.value = r.stats;
      } else {
        items.addAll(r.items);
      }
      _page = page;
      _totalPages = r.totalPages;
    } catch (_) {
      if (page == 1) loadFailed.value = true;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<bool> approve(SellerReturnItem i) => _run(i, () async {
        if (i.kind == ReturnKind.refundRequest) return _refunds.approve(i.requestId);
        return _orders.returnAction(
          orderId: i.orderId,
          storeId: _storeId ?? '',
          itemIds: i.itemIds,
          action: 'approve',
        );
      }, 'Return approved');

  Future<bool> reject(SellerReturnItem i, String reason) {
    if (validateRejectReason(reason) != null) return Future.value(false);
    return _run(i, () async {
      if (i.kind == ReturnKind.refundRequest) return _refunds.reject(i.requestId, reason.trim());
      return _orders.returnAction(
        orderId: i.orderId,
        storeId: _storeId ?? '',
        itemIds: i.itemIds,
        action: 'reject',
        rejectReason: reason.trim(),
      );
    }, 'Return rejected');
  }

  /// [step]: item_received | replacement_sent (offer only what the detail's
  /// `actions` allow; the server re-checks).
  Future<bool> followUp(SellerReturnItem i, String step) {
    if (i.requestId.isEmpty) return Future.value(false);
    return _run(
      i,
      () async {
        if (i.kind == ReturnKind.refundRequest) return _refunds.followUp(i.requestId, step);
        if (i.itemIds.isEmpty) return false;
        return _orders.returnFollowUp(orderId: i.orderId, storeId: _storeId ?? '', itemId: i.itemIds.first, step: step);
      },
      step == 'item_received' ? 'Marked as received' : 'Marked replacement sent',
    );
  }

  Future<bool> _run(SellerReturnItem i, Future<bool> Function() call, String done) async {
    final k = _key(i);
    if (_busy.contains(k)) return false;
    _busy.add(k);
    try {
      final ok = await call();
      if (ok) {
        ToastUtil.showToast(done);
        details.remove(k);
        // Re-read: the list endpoint is the source of truth.
        await refreshData();
      }
      return ok;
    } finally {
      _busy.remove(k);
    }
  }
}
