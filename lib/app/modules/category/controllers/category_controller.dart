import 'package:book_store_app/app/data/repositories/category_repository.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/category_with_children_response.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepo = CategoryRepository();

  var expandedIds = <String>{}.obs;

  // ─── State ────────────────────────────────────────────────────────────────
  final RxList<CategoryModel> categoryTrees = <CategoryModel>[].obs;
  final Rx<CategoryWithChildrenResponse?> categoryWithChildren =
      Rx<CategoryWithChildrenResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetails = false.obs;

  final RxString searchQuery = ''.obs;
  final RxList<CategoryModel> searchResults = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCategories();
  }

  // ─── Expand / collapse (for CategoryTile tree view) ──────────────────────

  void toggleExpand(String id) {
    if (expandedIds.contains(id)) {
      expandedIds.remove(id);
    } else {
      expandedIds.add(id);
    }
  }

  bool isExpanded(String id) => expandedIds.contains(id);

  // ─── Select category ──────────────────────────────────────────────────────
  /// Any category (main or sub) navigates straight to SubCategoryView, which
  /// renders that category's own subcategories as filter chips over a single
  /// product grid — matching the marketplace pattern (Daraz etc.) instead of
  /// forcing the user to drill through nested category screens.

  void selectCategory(CategoryModel category) {
    Get.toNamed(
      Routes.subCategoryView,
      arguments: {'categoryId': category.id, 'categoryName': category.name},
    );
  }

  // ─── 1. Fetch all category trees ─────────────────────────────────────────

  Future<void> fetchAllCategories() async {
    try {
      isLoading.value = true;
      final trees = await _categoryRepo.getAllCategoryTrees();
      categoryTrees.assignAll(trees);
      debugPrint('✅ Loaded ${trees.length} category trees');
    } catch (e) {
      debugPrint('❌ Error loading categories: $e');
      ToastUtil.showToast('Failed to load categories');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── 2. Fetch category with direct children ───────────────────────────────

  Future<void> fetchCategoryDetails(String categoryId) async {
    try {
      isLoadingDetails.value = true;
      final details = await _categoryRepo.getCategoryById(categoryId);
      if (details != null) {
        categoryWithChildren.value = details;
        debugPrint(
          '✅ Loaded category: ${details.category.name} '
          'with ${details.childrenCount} children',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading category details: $e');
      ToastUtil.showToast('Failed to load category details');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  // ─── Search categories ────────────────────────────────────────────────────

  Future<void> searchCategories(String query) async {
    searchQuery.value = query;

    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      final results = await _categoryRepo.searchCategories(query);
      searchResults.assignAll(results);
      debugPrint('✅ Found ${results.length} categories for "$query"');
    } catch (e) {
      debugPrint('❌ Search error: $e');
      searchResults.clear();
    }
  }

  // ─── Getters ──────────────────────────────────────────────────────────────

  List<CategoryModel> get rootCategories => categoryTrees;

  CategoryModel? findCategoryById(String categoryId) {
    for (final tree in categoryTrees) {
      final found = tree.findById(categoryId);
      if (found != null) return found;
    }
    return null;
  }

  List<CategoryModel> get allCategoriesFlat {
    final flatList = <CategoryModel>[];
    for (final tree in categoryTrees) {
      flatList.addAll(tree.flatten());
    }
    return flatList;
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  @override
  Future<void> refresh() async {
    await fetchAllCategories();
  }
}
