import 'dart:async';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart'
    as BackendModel;
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBarController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final textController = TextEditingController();

  /// user input
  RxString searchText = "".obs;
  RxBool showResults = false.obs;
  RxBool loading = false.obs;
  RxBool showSuggestions = false.obs;

  RxMap<String, bool> favouriteMap = <String, bool>{}.obs;

  Timer? debounce;

  @override
  void onClose() {
    // textController.dispose();
    debounce?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
    loadRecentlyViewed();
  }

  /// all products source (from backend)
  RxList<BackendModel.ProductModel> allProducts =
      <BackendModel.ProductModel>[].obs;

  /// filtered products
  RxList<BackendModel.ProductModel> filteredProducts =
      <BackendModel.ProductModel>[].obs;
  RxList<BackendModel.ProductModel> suggestions =
      <BackendModel.ProductModel>[].obs;

  /// called when user is typing
  void onSearchChanged(String value) {
    searchText.value = value;

    if (value.isEmpty) {
      showResults.value = false;
      showSuggestions.value = false;
      filteredProducts.clear();
      suggestions.clear();
      return;
    }

    showSuggestions.value = true;

    // Cancel previous debounce
    debounce?.cancel();

    // Show suggestions from local data if available
    if (allProducts.isNotEmpty) {
      suggestions.value = allProducts
          .where(
            (p) =>
                p.name.toLowerCase().startsWith(value.toLowerCase()) ||
                p.description.toLowerCase().contains(value.toLowerCase()),
          )
          .take(6)
          .toList();
    }

    // Debounce API call
    debounce = Timer(const Duration(milliseconds: 100), () {
      performSearch(value);
    });
  }

  /// Main search - calls backend API
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) return;

    loading.value = true;
    showResults.value = true;

    try {
      // Call backend search API
      final response = await _productRepository.getProducts(
        search: query,
        page: 1,
        limit: 50,
      );

      if (response != null && response.products.isNotEmpty) {
        filteredProducts.assignAll(response.products);
        allProducts.assignAll(response.products);

        // Update suggestions
        suggestions.value = response.products.take(1).toList();

        // Add to recent searches
        addToRecentSearches(query);

        // Initialize favorites
        for (var p in response.products) {
          favouriteMap[p.id] = false;
        }

        debugPrint('Search found ${response.products.length} products');
      } else {
        filteredProducts.clear();
        suggestions.clear();
        showResults.value = false;
        ToastUtil.showToast('No products found for "$query"');
      }
    } catch (e) {
      debugPrint('Search error: $e');
      ToastUtil.showToast('Search failed. Please try again.');
      filteredProducts.clear();
      suggestions.clear();
      showResults.value = false;
    } finally {
      loading.value = false;
    }
  }

  /// Select a suggestion and perform full search
  void selectSuggestion(BackendModel.ProductModel product) {
    textController.text = product.name;
    searchText.value = product.name;
    performSearch(product.name);
    showSuggestions.value = false;
  }

  /// Clear search
  void clearSearch() {
    searchText.value = "";
    textController.clear();
    filteredProducts.clear();
    suggestions.clear();
    showResults.value = false;
    showSuggestions.value = false;
  }

  // ==================== RECENT SEARCHES ====================

  /// Recent searches (stored locally)
  RxList<String> recentSearches = <String>[].obs;

  RxBool showAll = false.obs;

  List<String> get shownRecentSearches =>
      showAll.value ? recentSearches : recentSearches.take(4).toList();

  /// Load recent searches from storage
  Future<void> loadRecentSearches() async {
    try {
      // Load from SharedPreferences
      // final saved = await AppPreferences.getRecentSearches();
      // if (saved != null) {
      //   recentSearches.assignAll(saved);
      // }

      // Temporary dummy data
      recentSearches.assignAll([
        "desk storage",
        "hanger",
        "cabinet",
        "bracket",
      ]);
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  /// Save recent searches to storage
  Future<void> saveRecentSearches() async {
    try {
      // Save to SharedPreferences
      // await AppPreferences.saveRecentSearches(recentSearches);
      debugPrint('Recent searches saved');
    } catch (e) {
      debugPrint('Error saving recent searches: $e');
    }
  }

  /// Add to recent searches
  void addToRecentSearches(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    // Remove if already exists
    recentSearches.remove(trimmed);

    // Add to beginning
    recentSearches.insert(0, trimmed);

    // Keep only last 10
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }

    saveRecentSearches();
  }

  /// Delete a recent search
  void deleteRecent(String value) {
    recentSearches.remove(value);
    saveRecentSearches();
  }

  /// Toggle see more/less
  void toggleSeeMore() {
    showAll.value = !showAll.value;
  }

  /// Clear all recent searches
  void clearRecentSearches() {
    recentSearches.clear();
    saveRecentSearches();
  }

  // ==================== LAST SEEN / RECENTLY VIEWED ====================

  /// Last seen products (from backend)
  RxList<BackendModel.ProductModel> lastSeenProducts =
      <BackendModel.ProductModel>[].obs;

  /// Last seen images (temporary fallback)
  List<String> lastSeenImages = [
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
  ];

  /// Load recently viewed products
  Future<void> loadRecentlyViewed() async {
    try {
      // Load product IDs from storage
      final productIds = await AppPreferences.getRecentlyViewedProductIds();
      if (productIds != null && productIds.isNotEmpty) {
        // Fetch products from backend
        for (var id in productIds.take(6)) {
          final product = await _productRepository.getProductById(id);
          if (product != null) {
            lastSeenProducts.add(product);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading recently viewed: $e');
    }
  }

  /// Add product to recently viewed
  Future<void> addToRecentlyViewed(String productId) async {
    try {
      // Load existing IDs
      final ids = await AppPreferences.getRecentlyViewedProductIds() ?? [];
      ids.remove(productId);
      ids.insert(0, productId);
      if (ids.length > 20) {
        ids.removeRange(20, ids.length);
      }
      await AppPreferences.saveRecentlyViewedProductIds(ids);
      debugPrint('Added to recently viewed: $productId');
    } catch (e) {
      debugPrint('Error saving recently viewed: $e');
    }
  }

  // ==================== SEARCH FILTERS ====================

  /// Apply filters to search results
  void applyFilters({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    if (searchText.value.isEmpty) return;

    loading.value = true;

    try {
      final response = await _productRepository.getProducts(
        search: searchText.value,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: sortBy,
        page: 1,
        limit: 50,
      );

      if (response != null) {
        filteredProducts.assignAll(response.products);
      }
    } catch (e) {
      debugPrint('Filter error: $e');
      ToastUtil.showToast('Failed to apply filters');
    } finally {
      loading.value = false;
    }
  }

  /// Sort search results
  void sortResults(String sortBy) {
    applyFilters(sortBy: sortBy);
  }

  // ==================== POPULAR SEARCHES ====================

  /// Get popular/trending searches from backend
  Future<void> loadPopularSearches() async {
    // try {
    //   final popular = await _productRepository.getPopularSearches();
    //   if (popular != null) {
    //     popularSearches.assignAll(popular);
    //   }
    // } catch (e) {
    //   debugPrint('Error loading popular searches: $e');
    // }
  }

  /// Popular searches
  RxList<String> popularSearches = <String>[].obs;

  // ==================== UTILITIES ====================

  /// Check if a product is favorited
  bool isFavorite(String productId) {
    return favouriteMap[productId] ?? false;
  }

  /// Toggle favorite
  void toggleFavorite(String productId) {
    favouriteMap[productId] = !(favouriteMap[productId] ?? false);
  }

  /// Get total results count
  int get resultsCount => filteredProducts.length;

  /// Check if has results
  bool get hasResults => filteredProducts.isNotEmpty;

  /// Check if search is active
  bool get isSearching => searchText.value.isNotEmpty;
}
