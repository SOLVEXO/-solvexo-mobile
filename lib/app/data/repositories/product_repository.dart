import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProductRepository {
  final BaseClient _baseClient = BaseClient();

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

  /// Get featured products
  Future<List<ProductModel>?> getFeaturedProducts() async {
    try {
      final response = await _baseClient.get(ApiConstants.featuredProducts);

      debugPrint("Get Featured Products Response --> ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((product) => ProductModel.fromJson(product))
            .toList();
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Get Featured Products error --> $e");
      return null;
    }
  }

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

  /// Create new product (requires auth token)
  Future<ProductModel?> createProduct({
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required String categoryId,
    required List<String> images,
    required int stock,
    String? brand,
    Map<String, String>? specifications,
    List<String>? tags,
    bool isFeatured = false,
  }) async {
    try {
      final response = await _baseClient.post(
        ApiConstants.products,
        data: {
          'name': name,
          'description': description,
          'price': price,
          if (discountPrice != null) 'discountPrice': discountPrice,
          'category': categoryId,
          'images': images,
          'stock': stock,
          if (brand != null) 'brand': brand,
          if (specifications != null) 'specifications': specifications,
          if (tags != null) 'tags': tags,
          'isFeatured': isFeatured,
        },
      );

      debugPrint("Create Product Response --> ${response.data}");

      if (response.statusCode == 201 && response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Create Product error --> $e");
      return null;
    }
  }

  /// Update product (requires auth token)
  Future<ProductModel?> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? categoryId,
    List<String>? images,
    int? stock,
    String? brand,
    Map<String, String>? specifications,
    List<String>? tags,
    bool? isFeatured,
  }) async {
    try {
      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (discountPrice != null) data['discountPrice'] = discountPrice;
      if (categoryId != null) data['category'] = categoryId;
      if (images != null) data['images'] = images;
      if (stock != null) data['stock'] = stock;
      if (brand != null) data['brand'] = brand;
      if (specifications != null) data['specifications'] = specifications;
      if (tags != null) data['tags'] = tags;
      if (isFeatured != null) data['isFeatured'] = isFeatured;

      final response = await _baseClient.put(
        ApiConstants.updateProduct(productId),
        data: data,
      );

      debugPrint("Update Product Response --> ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ProductModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint("Update Product error --> $e");
      return null;
    }
  }

  /// Delete product (requires auth token)
  Future<bool> deleteProduct({required String productId}) async {
    try {
      final response = await _baseClient.delete(
        ApiConstants.deleteProduct(productId),
      );

      debugPrint("Delete Product Response --> ${response.data}");

      return response.statusCode == 200 && response.data['success'] == true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint("Delete Product error --> $e");
      return false;
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
