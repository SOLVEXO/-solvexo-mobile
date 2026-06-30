import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Status enum ───────────────────────────────────────────────────────────────

enum ProductStatus { all, active, draft, lowStock, outOfStock }

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
  // Extended fields (populated from edit/add flows)
  final String? variantId;
  final String? description;
  final double? compareAtPrice;
  // Physical-only
  final String? size;
  final String? color;
  final String? shippingWeight;
  final List<String> tags;
  // Digital-only
  final List<Map<String, dynamic>> digitalFiles;
  final String downloadLimit;
  final int? linkExpiryDays;
  final bool pdfStampingEnabled;
  final String licenseType;
  final String? buyerDeliveryMessage;
  final List<String> images;

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
    this.variantId,
    this.description,
    this.compareAtPrice,
    this.size,
    this.color,
    this.shippingWeight,
    this.tags = const [],
    this.digitalFiles = const [],
    this.downloadLimit = 'unlimited',
    this.linkExpiryDays,
    this.pdfStampingEnabled = false,
    this.licenseType = 'personal',
    this.buyerDeliveryMessage,
    this.images = const [],
  });

  bool get isUnlimitedStock => stock == null;
  String get stockLabel => isUnlimitedStock ? '∞' : '$stock';

  factory SellerProduct.fromApiJson(Map<String, dynamic> json) {
    // Stock: "∞ Unlimited" string → null, numeric → int
    final rawStock = json['stock'];
    final int? stock = rawStock is int ? rawStock : null;

    // Status resolution: draft wins, then stockStatus, then active
    final String apiStatus = json['status'] as String? ?? 'active';
    final String stockStatus = json['stockStatus'] as String? ?? 'active';

    final ProductStatus status;
    if (apiStatus == 'draft') {
      status = ProductStatus.draft;
    } else if (stockStatus == 'out_of_stock' || stock == 0) {
      status = ProductStatus.outOfStock;
    } else if (stockStatus == 'low_stock') {
      status = ProductStatus.lowStock;
    } else {
      status = ProductStatus.active;
    }

    // Type: "digital" → "Digital"
    final String rawType = json['type'] as String? ?? 'physical';
    final String type =
        rawType[0].toUpperCase() + rawType.substring(1).toLowerCase();

    final String name = json['name'] as String? ?? '';

    return SellerProduct(
      id: json['productId'] as String? ?? '',
      sku: json['sku'] as String?,
      name: name,
      emoji: _emojiFromName(name),
      image: json['image'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      type: type,
      status: status,
      sold: json['allTimeSales'] as int? ?? 0,
      stock: stock,
    );
  }

  // Deterministic emoji from name so it's consistent across rebuilds
  static String _emojiFromName(String name) {
    const emojis = [
      '📐', '☕', '🖼️', '➗', '🔬', '🧩', '📚', '📋', '💾', '🎨',
      '🧴', '👜', '📦', '🕯️', '✏️', '📷', '🎀', '📔', '💧', '🗝️',
      '🍜', '🐝', '🧸', '🎯', '🏆', '💡', '🔮', '🌿', '📱', '🖥️',
    ];
    if (name.isEmpty) return '📦';
    final idx = name.codeUnits.fold(0, (s, c) => s + c) % emojis.length;
    return emojis[idx];
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class SellerProductsController extends GetxController {
  final _repo = SellerProductRepository();

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final Rx<ProductStatus> selectedFilter = ProductStatus.all.obs;
  final RxString searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;

  final RxList<SellerProduct> _allProducts = <SellerProduct>[].obs;
  final RxInt totalProducts = 0.obs;

  int _page = 1;
  bool _hasMore = false;
  static const int _pageSize = 20;

  // ── Computed ──────────────────────────────────────────────────────────────

  List<SellerProduct> get filteredProducts {
    var list = selectedFilter.value == ProductStatus.all
        ? List<SellerProduct>.from(_allProducts)
        : _allProducts.where((p) => p.status == selectedFilter.value).toList();

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  bool get hasMore => _hasMore;

  int countFor(ProductStatus status) {
    if (status == ProductStatus.all) return totalProducts.value;
    return _allProducts.where((p) => p.status == status).length;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void setFilter(ProductStatus status) => selectedFilter.value = status;

  void onSearch(String query) => searchQuery.value = query;

  void clearSearch() => searchQuery.value = '';

  Future<void> refreshData() async {
    _page = 1;
    _hasMore = false;
    _allProducts.clear();
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
    errorMessage.value = '';

    try {
      final storeId = await AppPreferences.getStoreId();
      if (storeId == null || storeId.isEmpty) {
        debugPrint('⚠️ SellerProductsController: no storeId in prefs');
        isLoading.value = false;
        isLoadingMore.value = false;
        return;
      }

      final result = await _repo.fetchStoreInventory(
        storeId: storeId,
        page: page,
        limit: _pageSize,
      );

      final parsed = result.products
          .map((json) => SellerProduct.fromApiJson(json))
          .toList();

      if (page == 1) {
        _allProducts.assignAll(parsed);
      } else {
        _allProducts.addAll(parsed);
      }

      totalProducts.value = result.totalProducts;
      _hasMore = result.hasMore;
      _page = page;

      debugPrint(
          '✅ Loaded ${parsed.length} products (page $page, total ${result.totalProducts})');
    } catch (e) {
      debugPrint('❌ _load error: $e');
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
    _load();
  }
}
