import 'dart:async';

import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/utils/price_rules.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Status enum ───────────────────────────────────────────────────────────────

enum ProductStatus { all, active, draft, scheduled, lowStock, outOfStock }

// ── Model ─────────────────────────────────────────────────────────────────────

class SellerProduct {
  final String id;
  final String name;
  final String emoji;
  final String? image;
  final String? sku;
  final double price;
  final String type; // 'Digital' | 'Physical'
  final ProductStatus status;
  final int sold;
  final int? stock; // null = unlimited
  final DateTime? scheduledAt;
  // Extended fields (populated from edit/add flows)
  final String? variantId;
  final String? description;
  final double? compareAtPrice;
  // Physical-only
  final List<VariantOption> options;
  final String? shippingWeight;
  final int variantCount;
  final double? minPrice;
  final double? maxPrice;
  final List<String> tags;
  // Digital-only
  final List<Map<String, dynamic>> digitalFiles;
  final String downloadLimit;
  final int? linkExpiryDays;
  final bool pdfStampingEnabled;
  final String licenseType;
  final String? buyerDeliveryMessage;
  final bool previewEnabled;
  final List<String> images;

  /// Raw API status: draft | pending_review | active | scheduled | inactive |
  /// rejected (docs Part B 4).
  final String rawStatus;

  /// Hidden because the platform plan ended (docs 2.8).
  final bool pausedByPlan;

  /// Admin note for a listing sent back ("Fix now").
  final String? adminNote;
  final String? defaultVariantId;
  final List<String> qualityMissing;

  const SellerProduct({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.type,
    required this.status,
    required this.sold,
    this.image,
    this.sku,
    this.stock,
    this.scheduledAt,
    this.variantId,
    this.description,
    this.compareAtPrice,
    this.options = const [],
    this.shippingWeight,
    this.variantCount = 1,
    this.minPrice,
    this.maxPrice,
    this.tags = const [],
    this.digitalFiles = const [],
    this.downloadLimit = 'unlimited',
    this.linkExpiryDays,
    this.pdfStampingEnabled = false,
    this.licenseType = 'personal',
    this.buyerDeliveryMessage,
    this.previewEnabled = false,
    this.images = const [],
    this.rawStatus = 'active',
    this.pausedByPlan = false,
    this.adminNote,
    this.defaultVariantId,
    this.qualityMissing = const [],
  });

  bool get needsChanges => rawStatus == 'rejected';
  bool get inReview => rawStatus == 'pending_review';
  bool get isLive => rawStatus == 'active' || rawStatus == 'scheduled';
  bool get canActivate => rawStatus == 'inactive';
  bool get isPhysical => type == 'Physical';

  bool get isUnlimitedStock => stock == null;
  String get stockLabel => isUnlimitedStock ? '∞' : '$stock';
  bool get hasPriceRange =>
      variantCount > 1 && minPrice != null && maxPrice != null && minPrice != maxPrice;

  factory SellerProduct.fromApiJson(Map<String, dynamic> json) {
    // Stock: "∞ Unlimited" string → null, numeric → int
    final rawStock = json['stock'];
    final int? stock = rawStock is int ? rawStock : null;

    // Status resolution: draft/scheduled win, then stockStatus, then active
    final String apiStatus = json['status'] as String? ?? 'active';
    final String stockStatus = json['stockStatus'] as String? ?? 'active';

    final ProductStatus status;
    if (apiStatus == 'draft') {
      status = ProductStatus.draft;
    } else if (apiStatus == 'scheduled') {
      status = ProductStatus.scheduled;
    } else if (stockStatus == 'out_of_stock' || stock == 0) {
      status = ProductStatus.outOfStock;
    } else if (stockStatus == 'low_stock') {
      status = ProductStatus.lowStock;
    } else {
      status = ProductStatus.active;
    }

    final rawScheduledAt = json['scheduledAt'] as String?;

    // Type: "digital" → "Digital". The retired `educational` type was
    // migrated to Digital (docs Part B 11): legacy rows show as Digital.
    final String rawType = (json['type'] as String? ?? 'physical').toLowerCase();
    final String type = rawType == 'educational'
        ? 'Digital'
        : rawType[0].toUpperCase() + rawType.substring(1);

    final String name = json['name'] as String? ?? '';

    String? note(dynamic v) {
      if (v == null) return null;
      if (v is Map) return (v['note'] ?? v['reason'] ?? v['message'])?.toString();
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    // Digital config is nested under `digital` (null for physical products).
    final digitalJson = json['digital'] as Map<String, dynamic>?;

    return SellerProduct(
      id: json['productId'] as String? ?? '',
      sku: json['sku'] as String?,
      name: name,
      emoji: _emojiFromName(name),
      image: json['image'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
      type: type,
      status: status,
      sold: json['allTimeSales'] as int? ?? 0,
      stock: stock,
      scheduledAt: rawScheduledAt != null
          ? DateTime.tryParse(rawScheduledAt)
          : null,
      description: json['description'] as String?,
      options: (json['options'] as List? ?? [])
          .map((o) => VariantOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      shippingWeight: json['shippingWeight'] as String?,
      variantCount: json['variantCount'] as int? ?? 1,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      digitalFiles:
          (digitalJson?['files'] as List?)?.cast<Map<String, dynamic>>() ??
          const [],
      downloadLimit: digitalJson?['downloadLimit'] as String? ?? 'unlimited',
      linkExpiryDays: digitalJson?['linkExpiryDays'] as int?,
      pdfStampingEnabled: digitalJson?['pdfStampingEnabled'] as bool? ?? false,
      licenseType: digitalJson?['licenseType'] as String? ?? 'personal',
      buyerDeliveryMessage: digitalJson?['buyerDeliveryMessage'] as String?,
      previewEnabled:
          (digitalJson?['preview'] as Map?)?['enabled'] as bool? ?? false,
      rawStatus: apiStatus,
      pausedByPlan: json['pausedByPlan'] == true,
      adminNote: note(json['reviewNote']) ?? note(json['editRejection']) ?? note(json['reviewReason']),
      defaultVariantId: json['defaultVariantId'] as String?,
      qualityMissing: (json['qualityMissing'] as List?)?.map((e) => '$e').toList() ?? const [],
    );
  }

  // Deterministic emoji from name so it's consistent across rebuilds
  static String _emojiFromName(String name) {
    const emojis = [
      '📐',
      '☕',
      '🖼️',
      '➗',
      '🔬',
      '🧩',
      '📚',
      '📋',
      '💾',
      '🎨',
      '🧴',
      '👜',
      '📦',
      '🕯️',
      '✏️',
      '📷',
      '🎀',
      '📔',
      '💧',
      '🗝️',
      '🍜',
      '🐝',
      '🧸',
      '🎯',
      '🏆',
      '💡',
      '🔮',
      '🌿',
      '📱',
      '🖥️',
    ];
    if (name.isEmpty) return '📦';
    final idx = name.codeUnits.fold(0, (s, c) => s + c) % emojis.length;
    return emojis[idx];
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

/// Products tabs (docs Part B 6.3) = raw API status filters.
enum ProductsTab {
  all(null, 'All'),
  active('active', 'Active'),
  inReview('pending_review', 'In review'),
  needsChanges('rejected', 'Needs changes'),
  draft('draft', 'Draft'),
  inactive('inactive', 'Inactive');

  const ProductsTab(this.api, this.label);
  final String? api;
  final String label;

  static ProductsTab fromApi(String? s) =>
      ProductsTab.values.firstWhere((t) => t.api == s, orElse: () => ProductsTab.all);
}

class SellerProductsController extends GetxController {
  SellerProductsController({SellerProductRepository? repository})
      : _repo = repository ?? SellerProductRepository();

  final SellerProductRepository _repo;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool loadFailed = false.obs;
  final Rx<ProductsTab> selectedTab = ProductsTab.all.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;
  final TextEditingController searchController = TextEditingController();

  final RxList<SellerProduct> _allProducts = <SellerProduct>[].obs;
  final RxInt totalProducts = 0.obs;

  /// Server counts per raw status (stats.statusCounts, e.g. {draft: 2}).
  final RxMap<String, int> statusCounts = <String, int>{}.obs;

  /// Multi-select for bulk activate / deactivate.
  final RxSet<String> selectedIds = <String>{}.obs;
  final RxSet<String> busyIds = <String>{}.obs;

  int _page = 1;
  bool _hasMore = false;
  static const int _pageSize = 20;
  Timer? _searchDebounce;

  // ── Computed ──────────────────────────────────────────────────────────────

  /// Rows of the selected tab / search (filtered by the server).
  List<SellerProduct> get filteredProducts => List<SellerProduct>.from(_allProducts);

  bool get hasMore => _hasMore;
  bool get selecting => selectedIds.isNotEmpty;

  int countForTab(ProductsTab t) {
    if (t == ProductsTab.all) {
      return statusCounts.values.fold(0, (a, b) => a + b);
    }
    return statusCounts[t.api] ?? 0;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void setTab(ProductsTab t) {
    if (selectedTab.value == t) return;
    selectedTab.value = t;
    selectedIds.clear();
    refreshData();
  }

  void onSearch(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), refreshData);
  }

  void clearSearch() {
    searchQuery.value = '';
    refreshData();
  }

  void toggleSelect(String id) =>
      selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);

  void clearSelection() => selectedIds.clear();

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

  /// Validation for inline edits (same rules as the API / PriceRules).
  static String? validatePrice(String raw) {
    final v = double.tryParse(raw.trim());
    if (v == null) return 'Enter a price.';
    return PriceRules.validate(v);
  }

  static String? validateStock(String raw) {
    final v = int.tryParse(raw.trim());
    if (v == null || v < 0 || v > 1000000) return 'Stock must be a whole number from 0 to 1,000,000.';
    return null;
  }

  Future<bool> setPrice(SellerProduct p, String raw) async {
    if (validatePrice(raw) != null) return false;
    final price = double.parse(raw.trim());
    return _act(p.id, () async {
      final r = p.isPhysical && p.defaultVariantId != null
          ? await _repo.setVariantPrice(p.id, p.defaultVariantId!, price)
          : await _repo.setDigitalPrice(p.id, price);
      return (r.ok, r.ok ? 'Price updated' : (r.message ?? 'Could not change the price.'));
    });
  }

  Future<bool> setStock(SellerProduct p, String raw) async {
    if (validateStock(raw) != null || p.defaultVariantId == null) return false;
    final storeId = await AppPreferences.getStoreId() ?? '';
    return _act(p.id, () async {
      final r = await _repo.setVariantStock(storeId, p.defaultVariantId!, int.parse(raw.trim()));
      return (r.ok, r.ok ? 'Stock updated' : (r.message ?? 'Could not change the stock.'));
    });
  }

  Future<bool> duplicate(SellerProduct p) => _act(p.id, () async {
        final r = await _repo.duplicateProduct(p.id);
        return (r.ok, r.ok ? 'Draft copy created' : (r.message ?? 'Could not duplicate.'));
      });

  /// Single or bulk activate/deactivate. Returns the server's skipped
  /// reasons (e.g. "Only a live or scheduled product can be deactivated.").
  Future<List<String>> setActive(List<String> ids, {required bool active}) async {
    if (ids.isEmpty) return const [];
    busyIds.addAll(ids);
    try {
      final r = await _repo.setProductsActive(ids, active: active);
      if (r.updated > 0) {
        ToastUtil.showToast('${r.updated} product${r.updated == 1 ? '' : 's'} ${active ? 'activated' : 'deactivated'}');
      } else if (r.skipped.isEmpty && r.message != null) {
        ToastUtil.showToast(r.message!);
      }
      selectedIds.clear();
      await refreshData();
      return r.skipped;
    } finally {
      busyIds.removeAll(ids);
    }
  }

  Future<bool> _act(String id, Future<(bool, String)> Function() call) async {
    if (busyIds.contains(id)) return false;
    busyIds.add(id);
    try {
      final (ok, message) = await call();
      ToastUtil.showToast(message);
      if (ok) await refreshData();
      return ok;
    } finally {
      busyIds.remove(id);
    }
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> _load({int page = 1, bool isRefresh = false}) async {
    if (page == 1 && !isRefresh) {
      isLoading.value = true;
    } else if (page > 1) {
      isLoadingMore.value = true;
    }
    errorMessage.value = '';

    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) {
        loadFailed.value = true;
        return;
      }

      final result = await _repo.fetchStoreInventory(
        storeId: storeId,
        page: page,
        limit: _pageSize,
        status: selectedTab.value.api,
        query: searchQuery.value,
      );
      if (result.failed && page == 1) {
        loadFailed.value = true;
        _allProducts.clear();
        errorMessage.value = 'Failed to load products.';
        return;
      }
      loadFailed.value = false;

      final parsed = result.products.map((json) => SellerProduct.fromApiJson(json)).toList();
      if (page == 1) {
        _allProducts.assignAll(parsed);
        // Counts are store-wide only when the list is not narrowed by search.
        if (searchQuery.value.trim().isEmpty && selectedTab.value == ProductsTab.all) {
          statusCounts.assignAll(result.statusCounts);
        } else if (statusCounts.isEmpty) {
          statusCounts.assignAll(result.statusCounts);
        }
      } else {
        _allProducts.addAll(parsed);
      }
      totalProducts.value = result.totalProducts;
      _hasMore = result.hasMore;
      _page = page;
    } catch (e) {
      debugPrint('❌ _load error: $e');
      loadFailed.value = true;
      errorMessage.value = 'Failed to load products.';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // `listing_rejected` notifications open the "Needs changes" tab.
    final arg = Get.arguments;
    if (arg is Map && arg['tab'] is String) {
      selectedTab.value = ProductsTab.fromApi(arg['tab'] as String);
    }
    _load();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
