import 'package:book_store_app/app/data/models/refund_request_model.dart';
import 'package:book_store_app/app/data/repositories/refund_request_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

/// Client-side display filter over the seller's full loaded list — the
/// `refund-request/seller/:storeId` endpoint has no `status` query param, so
/// filtering happens locally rather than by re-querying the backend.
enum ReturnFilter { all, pending, approved, rejected }

// ── Controller ────────────────────────────────────────────────────────────────

class SellerReturnsController extends GetxController {
  final _repo = RefundRequestRepository();

  static const _limit = 20;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<ReturnFilter> selectedFilter = ReturnFilter.all.obs;
  final RxList<RefundRequestModel> requests = <RefundRequestModel>[].obs;
  final RxSet<String> _processingIds = <String>{}.obs;

  String? _storeId;
  int _page = 1;
  int _total = 0;

  bool get hasMore => requests.length < _total;

  bool isProcessing(String id) => _processingIds.contains(id);

  /// The currently loaded requests, narrowed to [selectedFilter].
  List<RefundRequestModel> get filteredRequests {
    final filter = selectedFilter.value;
    if (filter == ReturnFilter.all) return requests;
    return requests.where((r) => r.status == filter.name).toList();
  }

  int get pendingCount => requests.where((r) => r.isPending).length;
  int get approvedCount => requests.where((r) => r.isApproved).length;
  int get rejectedCount => requests.where((r) => r.isRejected).length;

  void setFilter(ReturnFilter filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
  }

  Future<void> refreshData() async {
    await _load(page: 1);
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore.value) return;
    await _load(page: _page + 1);
  }

  Future<void> _load({int page = 1}) async {
    if (page == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      _storeId ??= await AppPreferences.getStoreId();
      final storeId = _storeId;
      if (storeId == null || storeId.isEmpty) {
        debugPrint('⚠️ SellerReturnsController: no storeId in prefs');
        return;
      }

      final result = await _repo.listForSeller(storeId, page: page, limit: _limit);

      if (page == 1) {
        requests.assignAll(result.items);
      } else {
        requests.addAll(result.items);
      }
      _total = result.total;
      _page = page;
    } catch (e) {
      debugPrint('❌ SellerReturnsController._load error: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> approve(RefundRequestModel request) => _act(request, action: 'approve');

  Future<void> reject(RefundRequestModel request, String notes) =>
      _act(request, action: 'reject', notes: notes);

  Future<void> _act(
    RefundRequestModel request, {
    required String action,
    String? notes,
  }) async {
    if (_processingIds.contains(request.id)) return;
    _processingIds.add(request.id);
    try {
      final success = action == 'approve'
          ? await _repo.approve(request.id)
          : await _repo.reject(request.id, notes!);

      if (success) {
        ToastUtil.showToast(
          action == 'approve' ? 'Refund request approved' : 'Refund request rejected',
        );
        // Re-fetch rather than patch locally: approve/reject don't return the
        // updated refund/debit amounts, only success — the list endpoint is
        // the single source of truth for those.
        await refreshData();
      }
    } finally {
      _processingIds.remove(request.id);
    }
  }

  @override
  void onInit() {
    super.onInit();
    _load();
  }
}
