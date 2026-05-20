import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/sub_category/widgets/filter_bottom_sheet.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubCategoryController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  // ─── Arguments ────────────────────────────────────────────────────────────
  late final String categoryId;
  late final String categoryName;

  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<CategoryModel> subCategories = <CategoryModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxInt selectedSubCategoryIndex = 0.obs; // 0 = All

  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingSubCategories = false.obs;

  // ─── Pagination ───────────────────────────────────────────────────────────
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreProducts = true.obs;

  // ─── Filters ──────────────────────────────────────────────────────────────
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 1000.0.obs;
  final RxDouble currentMinFilter = 0.0.obs;
  final RxDouble currentMaxFilter = 1000.0.obs;
  final RxString selectedBrand = ''.obs;
  final RxDouble selectedRating = 0.0.obs;

  final List<double> ratings = [1, 2, 3, 4, 5];

  List<String> get brands {
    final uniqueBrands = products
        .where((p) => p.variants.isNotEmpty)
        .expand((p) => p.variants)
        .map((v) => v.sku.split('-').first)
        .toSet()
        .toList();
    return uniqueBrands.isEmpty
        ? ['Brand A', 'Brand B', 'Brand C']
        : uniqueBrands;
  }

  // ─── Currently selected sub-category ID ──────────────────────────────────
  String? get _activeSubCategoryId {
    if (selectedSubCategoryIndex.value == 0) return null; // All
    final idx = selectedSubCategoryIndex.value - 1;
    if (idx < subCategories.length) return subCategories[idx].id;
    return null;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    // Run both in parallel — sub-categories chip strip + initial products
    Future.wait([fetchSubCategories(), fetchProducts()]);
  }

  void _readArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    categoryId = args?['categoryId'] as String? ?? '';
    categoryName = args?['categoryName'] as String? ?? 'Products';
    debugPrint(
      '📦 SubCategoryController init — '
      'id: $categoryId, name: $categoryName',
    );
  }

  // ─── 1. Fetch sub-categories ──────────────────────────────────────────────
  // Reads children of the current category from CategoryController.
  // CategoryController already has the full tree loaded — no extra API call.

  Future<void> fetchSubCategories() async {
    try {
      isLoadingSubCategories.value = true;

      // Try to find this category in the already-loaded tree
      final categoryController = Get.find<CategoryController>();

      // Search flat list for this category
      CategoryModel? match;
      try {
        match = categoryController.allCategoriesFlat.firstWhere(
          (c) => c.id == categoryId,
        );
      } catch (_) {
        match = null;
      }

      if (match != null && match.children.isNotEmpty) {
        // Use locally-cached children — no extra network call
        subCategories.assignAll(match.children);
        debugPrint(
          '✅ SubCategories loaded from cache: ${match.children.length}',
        );
        return;
      }

      // Fallback: fetch category details from API if not in cache
      await categoryController.fetchCategoryDetails(categoryId);

      final fetched = categoryController.categoryWithChildren.value;
      if (fetched != null && fetched.children.isNotEmpty) {
        subCategories.assignAll(fetched.children);
        debugPrint(
          '✅ SubCategories loaded from API: ${fetched.children.length}',
        );
      } else {
        subCategories.clear();
        debugPrint('ℹ️ No sub-categories for $categoryId');
      }
    } catch (e) {
      debugPrint('❌ fetchSubCategories error: $e');
    } finally {
      isLoadingSubCategories.value = false;
    }
  }

  // ─── 2. Fetch products ────────────────────────────────────────────────────

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (isLoadingProducts.value) return;

    if (loadMore) {
      if (!hasMoreProducts.value) return;
      currentPage.value++;
    } else {
      currentPage.value = 1;
    }

    isLoadingProducts.value = true;

    try {
      final effectiveCategoryId = _activeSubCategoryId ?? categoryId;

      final response = await _productRepository.getProductsByCategory(
        categoryId: effectiveCategoryId.isNotEmpty ? effectiveCategoryId : null,
        page: currentPage.value,
        limit: 20,
      );

      if (response != null) {
        if (loadMore) {
          products.addAll(response.products);
        } else {
          products.assignAll(response.products);
        }
        totalPages.value = response.pages;
        hasMoreProducts.value = currentPage.value < totalPages.value;

        debugPrint(
          '✅ Fetched ${response.products.length} products '
          '(Page ${currentPage.value}/${totalPages.value})',
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching products: $e');
      ToastUtil.showToast('Failed to load products');
      if (loadMore) currentPage.value--;
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // ─── 3. Load more ─────────────────────────────────────────────────────────

  Future<void> loadMoreProducts() => fetchProducts(loadMore: true);

  // ─── 4. Select sub-category chip ─────────────────────────────────────────

  void selectSubCategory(int index) {
    if (selectedSubCategoryIndex.value == index) return;
    selectedSubCategoryIndex.value = index;
    fetchProducts();
  }

  // ─── 5. Filters ───────────────────────────────────────────────────────────

  void applyFilters() {
    currentMinFilter.value = minPrice.value;
    currentMaxFilter.value = maxPrice.value;
    fetchProducts();
  }

  void resetFilters() {
    selectedBrand.value = '';
    selectedRating.value = 0;
    minPrice.value = 0;
    maxPrice.value = 1000;
    currentMinFilter.value = 0;
    currentMaxFilter.value = 1000;
    fetchProducts();
  }

  void openFilterBottomSheet() {
    Get.bottomSheet(FilterBottomSheetSubCategory());
  }

  // ─── 6. Refresh ───────────────────────────────────────────────────────────

  @override
  Future<void> refresh() async {
    selectedSubCategoryIndex.value = 0;
    await Future.wait([fetchSubCategories(), fetchProducts()]);
  }
}
