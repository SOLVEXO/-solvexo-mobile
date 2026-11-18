import 'dart:async';

import 'package:book_store_app/app/data/repositories/seller_inventory_repository.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum BulkStockMode { set, add, subtract }

/// Inventory (docs 6.4; checklist #13): physical products, -/+ stock with an
/// unsaved-changes bar, bulk set/add/subtract, per-product low-stock limit
/// and stock history. English only.
class SellerInventoryController extends GetxController {
  SellerInventoryController({SellerInventoryRepository? repository, String? storeId})
      : _repo = repository ?? SellerInventoryRepository(),
        _storeIdOverride = storeId;

  final SellerInventoryRepository _repo;
  final String? _storeIdOverride;
  String _storeId = '';

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool failed = false.obs;
  final RxBool saving = false.obs;
  final RxList<SellerProduct> products = <SellerProduct>[].obs;
  final Rx<InventoryStats> stats = const InventoryStats().obs;
  final RxString query = ''.obs;

  /// Unsaved stock per product id (single-variant products only).
  final RxMap<String, int> pending = <String, int>{}.obs;
  final RxSet<String> selectedIds = <String>{}.obs;

  int _page = 1;
  bool _hasMore = false;
  Timer? _debounce;

  bool get hasMore => _hasMore;
  bool get dirty => pending.isNotEmpty;

  static const int maxStock = 1000000;
  static const int maxBulkValue = 100000; // server: "between 0 and 100000"

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  /// Stock can be edited here only when the product has one variant.
  static bool editable(SellerProduct p) => p.variantCount == 1 && p.defaultVariantId != null && p.stock != null;

  int shownStock(SellerProduct p) => pending[p.id] ?? p.stock ?? 0;

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    _storeId = _storeIdOverride ?? await AppPreferences.getStoreId() ?? '';
    await _fetch(1);
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await _fetch(_page + 1);
    isLoadingMore.value = false;
  }

  void onSearch(String q) {
    query.value = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), load);
  }

  Future<void> _fetch(int page) async {
    try {
      final r = await _repo.fetchPhysical(storeId: _storeId, page: page, query: query.value);
      final rows = r.rows.map(SellerProduct.fromApiJson).toList();
      page == 1 ? products.assignAll(rows) : products.addAll(rows);
      stats.value = r.stats;
      _hasMore = r.hasMore;
      _page = page;
    } catch (e) {
      debugPrint('inventory load: $e');
      if (page == 1) failed.value = true;
    }
  }

  void bump(SellerProduct p, int delta) {
    if (!editable(p)) return;
    final next = (shownStock(p) + delta).clamp(0, maxStock);
    if (next == p.stock) {
      pending.remove(p.id);
    } else {
      pending[p.id] = next;
    }
  }

  void setPending(SellerProduct p, int value) {
    if (!editable(p)) return;
    if (value == p.stock) {
      pending.remove(p.id);
    } else {
      pending[p.id] = value.clamp(0, maxStock);
    }
  }

  void discard() => pending.clear();

  /// Products that would be set to zero (the view asks to confirm).
  List<SellerProduct> get pendingZero =>
      products.where((p) => pending[p.id] == 0).toList();

  /// Saves the unsaved -/+ changes in one call. Returns skipped reasons.
  Future<List<String>> save() async {
    if (pending.isEmpty) return const [];
    final byVariant = <String, int>{
      for (final p in products)
        if (pending.containsKey(p.id) && p.defaultVariantId != null) p.defaultVariantId!: pending[p.id]!,
    };
    saving.value = true;
    try {
      final r = await _repo.setStocks(_storeId, byVariant);
      if (r.updated > 0) {
        ToastUtil.showToast('Stock saved');
        pending.clear();
        await _fetch(1);
      } else if (r.skipped.isEmpty) {
        ToastUtil.showToast(r.message ?? 'Nothing changed.');
      }
      return r.skipped;
    } finally {
      saving.value = false;
    }
  }

  static String? validateBulkValue(String raw) {
    final v = int.tryParse(raw.trim());
    if (v == null || v < 0 || v > maxBulkValue) return 'Enter a whole number from 0 to 100,000.';
    return null;
  }

  Future<List<String>> bulk(BulkStockMode mode, int value) async {
    final ids = selectedIds.toList();
    if (ids.isEmpty) return const [];
    saving.value = true;
    try {
      final r = await _repo.bulkStock(_storeId, mode: mode.name, productIds: ids, value: value);
      if (r.updated > 0) {
        ToastUtil.showToast('${r.updated} product${r.updated == 1 ? '' : 's'} updated');
        selectedIds.clear();
        pending.removeWhere((k, _) => ids.contains(k));
        await _fetch(1);
      } else if (r.skipped.isEmpty) {
        ToastUtil.showToast(r.message ?? 'Nothing changed.');
      }
      return r.skipped;
    } finally {
      saving.value = false;
    }
  }

  void toggleSelect(String id) =>
      selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);

  static String? validateThreshold(String raw) {
    final v = int.tryParse(raw.trim());
    if (v == null || v < 0 || v > 1000) return 'Enter a whole number from 0 to 1000.';
    return null;
  }

  /// [threshold] null = back to the default.
  Future<bool> setThreshold(SellerProduct p, int? threshold) async {
    final r = await _repo.setLowStockThreshold(_storeId, p.id, threshold);
    ToastUtil.showToast(r.ok ? 'Low-stock limit saved' : (r.message ?? 'Could not save the limit.'));
    if (r.ok) await _fetch(1);
    return r.ok;
  }

  Future<List<StockHistoryEntry>> history(SellerProduct p) => _repo.stockHistory(_storeId, p.id);
}
