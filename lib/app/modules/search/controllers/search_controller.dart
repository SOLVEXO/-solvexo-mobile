import 'dart:async';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBarController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final TextEditingController textController = TextEditingController();

  // ─── UI state ──────────────────────────────────────────────────────────────
  final RxString searchText = ''.obs;
  final RxBool showResults = false.obs;
  final RxBool loading = false.obs;
  final RxBool showSuggestions = false.obs;

  // ─── Products ─────────────────────────────────────────────────────────────
  // ProductModel is now variants-based — use product.price, product.stock,
  // product.averageRating computed getters; no alias import needed.
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> suggestions = <ProductModel>[].obs;

  // ─── Favourites ───────────────────────────────────────────────────────────
  final RxMap<String, bool> favouriteMap = <String, bool>{}.obs;

  Timer? _debounce;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
    loadRecentlyViewed();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    super.onClose();
  }

  // ─── 1. Typing handler ────────────────────────────────────────────────────

  void onSearchChanged(String value) {
    searchText.value = value;

    if (value.trim().isEmpty) {
      _clearState();
      return;
    }

    showSuggestions.value = true;

    // Instant suggestions from already-loaded products
    if (allProducts.isNotEmpty) {
      suggestions.assignAll(
        allProducts
            .where(
              (p) =>
                  p.name.toLowerCase().startsWith(value.toLowerCase()) ||
                  p.description.toLowerCase().contains(value.toLowerCase()),
            )
            .take(6)
            .toList(),
      );
    }

    // Debounced API call — 400ms feels natural for search
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      performSearch(value);
    });
  }

  // ─── 2. Main search ───────────────────────────────────────────────────────
  // Uses getProductsByCategory without a categoryId so the backend returns
  // all products matching the search query (same pattern as HomeController).

  Future<void> performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    loading.value = true;
    showResults.value = true;

    try {
      final response = await _productRepository.getProductsByCategory(
        categoryId: null, // search across all categories
        page: 1,
        limit: 50,
      );

      if (response != null && response.products.isNotEmpty) {
        // Client-side name/description filter on top of API results
        final matched = response.products
            .where(
              (p) =>
                  p.name.toLowerCase().contains(trimmed.toLowerCase()) ||
                  p.description.toLowerCase().contains(trimmed.toLowerCase()),
            )
            .toList();

        filteredProducts.assignAll(matched);
        allProducts.assignAll(
          response.products,
        ); // cache full list for suggestions

        // Top suggestion is the closest name match
        suggestions.assignAll(
          matched
              .where(
                (p) => p.name.toLowerCase().startsWith(trimmed.toLowerCase()),
              )
              .take(5)
              .toList(),
        );

        _updateFavouriteMap(matched);
        addToRecentSearches(trimmed);

        debugPrint('🔍 Search "$trimmed" → ${matched.length} results');

        if (matched.isEmpty) {
          showResults.value = false;
          ToastUtil.showToast('No products found for "$trimmed"');
        }
      } else {
        filteredProducts.clear();
        suggestions.clear();
        showResults.value = false;
        ToastUtil.showToast('No products found for "$trimmed"');
      }
    } catch (e) {
      debugPrint('❌ Search error: $e');
      ToastUtil.showToast('Search failed. Please try again.');
      filteredProducts.clear();
      suggestions.clear();
      showResults.value = false;
    } finally {
      loading.value = false;
    }
  }

  // ─── 3. Select a suggestion ───────────────────────────────────────────────

  void selectSuggestion(ProductModel product) {
    textController.text = product.name;
    searchText.value = product.name;
    showSuggestions.value = false;
    performSearch(product.name);
  }

  // ─── 4. Clear ─────────────────────────────────────────────────────────────

  void clearSearch() {
    textController.clear();
    _clearState();
  }

  void _clearState() {
    searchText.value = '';
    filteredProducts.clear();
    suggestions.clear();
    showResults.value = false;
    showSuggestions.value = false;
  }

  // ─── 5. Filters ───────────────────────────────────────────────────────────
  // Applies price / sort on the already-loaded filteredProducts list so
  // there is no extra API round-trip for simple filter changes.

  void applyFilters({double? minPrice, double? maxPrice, String? sortBy}) {
    if (allProducts.isEmpty) return;

    var result = allProducts.toList();

    // Re-apply the current search text filter
    final query = searchText.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query),
          )
          .toList();
    }

    // Price — uses product.price computed getter (min variant price)
    if (minPrice != null) {
      result = result.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      result = result.where((p) => p.price <= maxPrice).toList();
    }

    // Sort
    switch (sortBy ?? 'newest') {
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        // averageRating is a direct field on the new ProductModel
        result.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case 'newest':
      default:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    filteredProducts.assignAll(result);
    debugPrint('🎛️ Filtered to ${filteredProducts.length} products');
  }

  void sortResults(String sortBy) => applyFilters(sortBy: sortBy);

  // ─── 6. Recent searches ───────────────────────────────────────────────────

  final RxList<String> recentSearches = <String>[].obs;
  final RxBool showAll = false.obs;

  List<String> get shownRecentSearches =>
      showAll.value ? recentSearches : recentSearches.take(4).toList();

  Future<void> loadRecentSearches() async {
    try {
      // Uncomment when SharedPreferences method is ready:
      // final saved = await AppPreferences.getRecentSearches();
      // if (saved != null) recentSearches.assignAll(saved);

      // Placeholder dummy data
      recentSearches.assignAll([
        'desk storage',
        'hanger',
        'cabinet',
        'bracket',
      ]);
    } catch (e) {
      debugPrint('❌ Error loading recent searches: $e');
    }
  }

  Future<void> _saveRecentSearches() async {
    try {
      // await AppPreferences.saveRecentSearches(recentSearches);
    } catch (e) {
      debugPrint('❌ Error saving recent searches: $e');
    }
  }

  void addToRecentSearches(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    recentSearches.remove(trimmed);
    recentSearches.insert(0, trimmed);
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }
    _saveRecentSearches();
  }

  void deleteRecent(String value) {
    recentSearches.remove(value);
    _saveRecentSearches();
  }

  void toggleSeeMore() => showAll.value = !showAll.value;

  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  // ─── 7. Recently viewed ───────────────────────────────────────────────────

  final RxList<ProductModel> lastSeenProducts = <ProductModel>[].obs;

  /// Fallback images shown before lastSeenProducts loads
  final List<String> lastSeenImages = List.filled(6, AppImages.sampleProduct);

  Future<void> loadRecentlyViewed() async {
    try {
      final ids = await AppPreferences.getRecentlyViewedProductIds();
      if (ids == null || ids.isEmpty) return;

      for (final id in ids.take(6)) {
        final product = await _productRepository.getProductById(id);
        if (product != null) lastSeenProducts.add(product);
      }
    } catch (e) {
      debugPrint('❌ Error loading recently viewed: $e');
    }
  }

  Future<void> addToRecentlyViewed(String productId) async {
    try {
      final ids = await AppPreferences.getRecentlyViewedProductIds() ?? [];
      ids.remove(productId);
      ids.insert(0, productId);
      if (ids.length > 20) ids.removeRange(20, ids.length);
      await AppPreferences.saveRecentlyViewedProductIds(ids);
    } catch (e) {
      debugPrint('❌ Error saving recently viewed: $e');
    }
  }

  // ─── 8. Popular searches ──────────────────────────────────────────────────

  final RxList<String> popularSearches = <String>[].obs;

  Future<void> loadPopularSearches() async {
    // Uncomment when endpoint is ready:
    // try {
    //   final popular = await _productRepository.getPopularSearches();
    //   if (popular != null) popularSearches.assignAll(popular);
    // } catch (e) {
    //   debugPrint('Error loading popular searches: $e');
    // }
  }

  // ─── 9. Utilities ─────────────────────────────────────────────────────────

  bool isFavorite(String productId) => favouriteMap[productId] ?? false;

  void toggleFavorite(String productId) {
    favouriteMap[productId] = !(favouriteMap[productId] ?? false);
  }

  int get resultsCount => filteredProducts.length;
  bool get hasResults => filteredProducts.isNotEmpty;
  bool get isSearching => searchText.value.isNotEmpty;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _updateFavouriteMap(List<ProductModel> list) {
    for (final p in list) {
      favouriteMap.putIfAbsent(p.id, () => false);
    }
  }
}
