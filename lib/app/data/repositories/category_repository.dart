import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/category_with_children_response.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CategoryRepository {
  final BaseClient _baseClient = BaseClient();

  // ─────────────────────────────────────────
  // 1. GET ALL CATEGORY TREES (Full Hierarchy)
  // ─────────────────────────────────────────
  /// Get all categories
  Future<List<CategoryModel>?> getCategories() async {
    try {
      final response = await _baseClient.get(ApiConstants.categories);

      debugPrint("Get Categories Response --> ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((category) => CategoryModel.fromJson(category))
            .toList();
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Get Categories error --> $e");
      return null;
    }
  }

  Future<List<CategoryModel>> getAllCategoryTrees() async {
    try {
      debugPrint('🔄 Fetching all category trees...');

      final response = await _baseClient.get(ApiConstants.categories);

      debugPrint('✅ Category Trees Response: ${response.data}');

      if (response.data['data'] != null) {
        final List data = response.data['data'] as List;
        final categories = data
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint('✅ Parsed ${categories.length} root categories');
        return categories;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error fetching category trees: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // 2. GET CATEGORY TREE BY ID (Specific subtree)
  // ─────────────────────────────────────────

  Future<CategoryModel?> getCategoryTreeById(String categoryId) async {
    try {
      debugPrint('🔄 Fetching category tree for: $categoryId');

      final response = await _baseClient.get(
        ApiConstants.getCategoryTree(categoryId),
      );

      debugPrint('✅ Category Tree Response: ${response.data}');

      if (response.data != null) {
        // Response is the category object directly
        return CategoryModel.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching category tree by ID: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // 3. GET CATEGORY WITH DIRECT CHILDREN ONLY
  // ─────────────────────────────────────────

  Future<CategoryWithChildrenResponse?> getCategoryById(
    String categoryId,
  ) async {
    try {
      debugPrint('🔄 Fetching category with children: $categoryId');

      final response = await _baseClient.get(
        ApiConstants.getCategoryById(categoryId),
      );

      debugPrint('✅ Category By ID Response: ${response.data}');

      if (response.data['data'] != null) {
        return CategoryWithChildrenResponse.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error fetching category by ID: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────
  // HELPER: Get only root categories (no children)
  // ─────────────────────────────────────────

  Future<List<CategoryModel>> getRootCategories() async {
    final allTrees = await getAllCategoryTrees();
    return allTrees; // These are already root categories
  }

  // ─────────────────────────────────────────
  // HELPER: Search categories by name (all levels)
  // ─────────────────────────────────────────

  Future<List<CategoryModel>> searchCategories(String query) async {
    final allTrees = await getAllCategoryTrees();
    final results = <CategoryModel>[];

    for (final tree in allTrees) {
      // Flatten the tree and search
      final flatList = tree.flatten();
      results.addAll(
        flatList.where(
          (cat) => cat.name.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }

    return results;
  }

  // ─────────────────────────────────────────
  // HELPER: Get all categories as flat list
  // ─────────────────────────────────────────

  Future<List<CategoryModel>> getAllCategoriesFlat() async {
    final allTrees = await getAllCategoryTrees();
    final flatList = <CategoryModel>[];

    for (final tree in allTrees) {
      flatList.addAll(tree.flatten());
    }

    return flatList;
  }
}
