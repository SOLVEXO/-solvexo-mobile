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
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  final Rx<CategoryWithChildrenResponse?> categoryWithChildren =
      Rx<CategoryWithChildrenResponse?>(null);
  final RxList<CategoryModel> navigationStack = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingTree = false.obs;
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
  /// • If the category has children  → drill down inside CategoryView
  ///   (adds to navigationStack, loads details).
  /// • If the category has NO children → navigate to SubCategoryView
  ///   so the user can browse products for that leaf category.

  void selectCategory(CategoryModel category) {
    if (!category.hasChildren) {
      // Leaf category → go straight to products
      Get.toNamed(
        Routes.subCategoryView,
        arguments: {'categoryId': category.id, 'categoryName': category.name},
      );
      return;
    }

    // Parent category → drill down in-place
    navigationStack.add(category);
    selectedCategory.value = category;
    fetchCategoryDetails(category.id);
  }

  // ─── Go back one level ────────────────────────────────────────────────────

  void goBack() {
    if (navigationStack.isNotEmpty) {
      navigationStack.removeLast();
    }

    if (navigationStack.isEmpty) {
      selectedCategory.value = null;
      categoryWithChildren.value = null;
    } else {
      final last = navigationStack.last;
      selectedCategory.value = last;
      fetchCategoryDetails(last.id);
    }
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

  // ─── 2. Fetch category tree by ID ────────────────────────────────────────

  Future<void> fetchCategoryTree(String categoryId) async {
    try {
      isLoadingTree.value = true;
      final tree = await _categoryRepo.getCategoryTreeById(categoryId);
      if (tree != null) {
        selectedCategory.value = tree;
        debugPrint('✅ Loaded category tree: ${tree.name}');
      }
    } catch (e) {
      debugPrint('❌ Error loading category tree: $e');
      ToastUtil.showToast('Failed to load category tree');
    } finally {
      isLoadingTree.value = false;
    }
  }

  // ─── 3. Fetch category with direct children ───────────────────────────────

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

  // ─── Clear selection ──────────────────────────────────────────────────────

  void clearSelection() {
    selectedCategory.value = null;
    categoryWithChildren.value = null;
    navigationStack.clear();
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  @override
  Future<void> refresh() async {
    await fetchAllCategories();
  }
}
