import 'dart:async';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchBarController extends GetxController {
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
    textController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

    for (var p in allProducts) {
      favouriteMap[p.name] = false;
    }
  }

  /// all products source (API replaceable later)
  RxList<ProductModel> allProducts = <ProductModel>[
    ProductModel(
      customerReviews: [],
      variants: [],
      name: "Pallra Mini Chest",
      image: AppImages.sampleProduct,
      description: "Mini chest with 3 drawers, black painted",
      price: 14.29,
      rating: 4.9,
      reviews: 12,
      category: 'Home Decor',
    ),
    ProductModel(
      variants: [],
      customerReviews: [],
      name: "Wood Box",
      image: AppImages.sampleProduct,
      description: "Wood storage box with strong frame",
      price: 10.32,
      rating: 4.1,
      reviews: 32,
      category: 'Kitchen & Dining',
    ),
  ].obs;

  /// filtered products
  RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  RxList<ProductModel> suggestions = <ProductModel>[].obs;

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
    showResults.value = true;
    if (filteredProducts.isEmpty) {
      showResults.value = false;
    }

    suggestions.value = allProducts
        .where(
          (p) =>
              p.name.toLowerCase().startsWith(value.toLowerCase()) ||
              p.description.toLowerCase().contains(value.toLowerCase()),
        )
        .take(6) // LIMIT suggestions
        .toList();
    loading.value = true;

    // debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 900), () {
      filterProducts(value);
      loading.value = false;
    });
  }

  void selectSuggestion(ProductModel product) {
    textController.text = product.name;
    performSearch(product.name);
  }

  /// main filtering logic
  void filterProducts(String query) {
    filteredProducts.value = allProducts.where((p) {
      final q = query.toLowerCase();

      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }

  /// clear button in textField suffix
  void clearSearch() {
    searchText.value = "";
    textController.clear();
    filteredProducts.clear();
    showResults.value = false;
  }

  /// recent searches
  RxList<String> recentSearches = [
    "desk storage",
    "hanger",
    "cabinet",
    "bracket",
    "chair",
    "organizer",
    "basket",
  ].obs;

  RxBool showAll = false.obs;

  List<String> get shownRecentSearches =>
      showAll.value ? recentSearches : recentSearches.take(4).toList();

  /// last seen items → will convert to ProductModel later
  List<String> lastSeenImages = [
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
    AppImages.sampleProduct,
  ];

  void deleteRecent(String value) {
    recentSearches.remove(value);
  }

  void toggleSeeMore() {
    showAll.value = !showAll.value;
  }

  /// add selected search to recent
  void performSearch(String value) {
    searchText.value = value;

    if (value.trim().isEmpty) return;

    if (!recentSearches.contains(value)) {
      recentSearches.insert(0, value);
    }
  }
}
