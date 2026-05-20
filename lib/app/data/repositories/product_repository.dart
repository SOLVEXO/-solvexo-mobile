import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/product_details/models/product_detail_response.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProductRepository {
  final BaseClient _baseClient = BaseClient();
  Future<ProductListResponse?> getProductsByCategory({
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = ApiConstants.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
      );
      final response = await _baseClient.get(url);
      if (response.data['success'] == true) {
        return ProductListResponse.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    }
  }

  /// Get all products with filters
  Future<ProductListResponse?> getProducts({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = ApiConstants.getProductsWithFilters(
        search: search,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        brand: brand,
        sort: sort,
        page: page,
        limit: limit,
      );

      final response = await _baseClient.get(url);

      debugPrint("Get Products Response --> ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProductListResponse.fromJson(response.data);
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Get Products error --> $e");
      return null;
    }
  }

  // /// Get featured products
  // Future<List<ProductModel>?> getFeaturedProducts() async {
  //   try {
  //     final response = await _baseClient.get(ApiConstants.featuredProducts);

  //     debugPrint("Get Featured Products Response --> ${response.data}");

  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       return (response.data['data'] as List)
  //           .map((product) => ProductModel.fromJson(product))
  //           .toList();
  //     }

  //     return null;
  //   } on DioException catch (e) {
  //     DioExceptionHandler.handleDioException(e);
  //     return null;
  //   } catch (e) {
  //     debugPrint("Get Featured Products error --> $e");
  //     return null;
  //   }
  // }

  /// Get single product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _baseClient.get(
        ApiConstants.getProductById(productId),
      );

      debugPrint("Get Product By ID Response --> ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Get Product By ID error --> $e");
      return null;
    }
  }

  Future<ProductDetailResponse?> getProductDetailById(String id) async {
    try {
      final response = await _baseClient.get(ApiConstants.getProductById(id));
      if (response.data['success'] == true) {
        return ProductDetailResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    }
  }

  Future<VariantDetailResponse?> getVariantById(String variantId) async {
    try {
      final response = await _baseClient.get(
        ApiConstants.getVariantById(variantId),
      );
      if (response.data['success'] == true) {
        return VariantDetailResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    }
  }

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
}
