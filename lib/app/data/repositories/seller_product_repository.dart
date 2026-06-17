import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SellerProductRepository {
  final BaseClient _client = BaseClient();

  // ─── POST /api/products/edit-product (digital) ───────────────────────────

  Future<bool> editDigitalProduct({
    required String productId,
    String? variantId,
    required String name,
    required double price,
    required String status,
    String? description,
    double? compareAtPrice,
    List<Map<String, dynamic>> files = const [],
    String downloadLimit = 'unlimited',
    int? linkExpiryDays,
    bool pdfStampingEnabled = false,
    String licenseType = 'personal',
    String? buyerDeliveryMessage,
  }) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        'variantId': variantId,
        'name': name,
        'price': price,
        'status': status,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        'digital': {
          'files': files,
          'downloadLimit': downloadLimit,
          'linkExpiryDays': linkExpiryDays,
          'pdfStampingEnabled': pdfStampingEnabled,
          'licenseType': licenseType,
          if (buyerDeliveryMessage != null && buyerDeliveryMessage.isNotEmpty)
            'buyerDeliveryMessage': buyerDeliveryMessage,
        },
      };

      debugPrint('📤 editDigitalProduct → ${ApiConstants.editProduct}');
      debugPrint('   body: $body');

      final response = await _client.post(
        ApiConstants.editProduct,
        data: body,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final product = response.data['data']['product'];
        debugPrint('✅ Digital product updated: ${product['name']} (${product['_id']})');
        return true;
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to update product.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ editDigitalProduct DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ editDigitalProduct error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── POST /api/products/edit-product (physical) ───────────────────────────

  Future<bool> editPhysicalProduct({
    required String productId,
    String? variantId,
    required String name,
    required double price,
    required String status,
    String? description,
    double? compareAtPrice,
    int? stock,
    String? size,
    String? color,
    String? shippingWeight,
    List<String> tags = const [],
  }) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        'variantId': variantId,
        'name': name,
        'price': price,
        'status': status,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (stock != null) 'stock': stock,
        if (size != null && size.isNotEmpty) 'size': size,
        if (color != null && color.isNotEmpty) 'color': color,
        if (shippingWeight != null && shippingWeight.isNotEmpty)
          'shippingWeight': shippingWeight,
        if (tags.isNotEmpty) 'tags': tags,
      };

      debugPrint('📤 editPhysicalProduct → ${ApiConstants.editProduct}');
      debugPrint('   body: $body');

      final response = await _client.post(
        ApiConstants.editProduct,
        data: body,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final product = response.data['data']['product'];
        debugPrint('✅ Product updated: ${product['name']} (${product['_id']})');
        return true;
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to update product.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ editPhysicalProduct DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ editPhysicalProduct error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── POST /api/products/add-digital-product ───────────────────────────────

  Future<bool> addDigitalProduct({
    required String storeId,
    required String name,
    required double price,
    required String status,
    String? description,
    double? compareAtPrice,
    List<String> tags = const [],
    bool isListedOnSolvexo = false,
    String? subCategoryId,
    // digital object
    List<Map<String, dynamic>> files = const [],
    String downloadLimit = 'unlimited', // "unlimited" | number string
    int? linkExpiryDays,
    bool pdfStampingEnabled = false,
    String licenseType = 'personal',
    String? buyerDeliveryMessage,
  }) async {
    try {
      final body = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        'price': price,
        'status': status,
        'productType': 'digital',
        'isListedOnSolvexo': isListedOnSolvexo,
        'images': <String>[],
        'subCategoryId': subCategoryId,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (tags.isNotEmpty) 'tags': tags,
        'digital': {
          'files': files,
          'downloadLimit': downloadLimit,
          'linkExpiryDays': linkExpiryDays,
          'pdfStampingEnabled': pdfStampingEnabled,
          'licenseType': licenseType,
          if (buyerDeliveryMessage != null &&
              buyerDeliveryMessage.isNotEmpty)
            'buyerDeliveryMessage': buyerDeliveryMessage,
        },
      };

      debugPrint('📤 addDigitalProduct → ${ApiConstants.addDigitalProduct}');
      debugPrint('   body: $body');

      final response = await _client.post(
        ApiConstants.addDigitalProduct,
        data: body,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final product = response.data['data']['product'];
        debugPrint('✅ Digital product created: ${product['name']} (${product['_id']})');
        return true;
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to create product.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ addDigitalProduct DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ addDigitalProduct error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── POST /api/products/add-physical-product ──────────────────────────────

  Future<bool> addPhysicalProduct({
    required String storeId,
    required String name,
    required double price,
    required String status, // "active" | "draft"
    String? description,
    double? compareAtPrice,
    int? stock, // null = unlimited (no stock tracking)
    String? size,
    String? color,
    String? shippingWeight,
    List<String> tags = const [],
    bool isListedOnSolvexo = false,
    String? subCategoryId,
  }) async {
    try {
      final body = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        'price': price,
        'status': status,
        'isListedOnSolvexo': isListedOnSolvexo,
        'images': <String>[],
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (stock != null) 'stock': stock,
        if (size != null && size.isNotEmpty) 'size': size,
        if (color != null && color.isNotEmpty) 'color': color,
        if (shippingWeight != null && shippingWeight.isNotEmpty)
          'shippingWeight': shippingWeight,
        if (tags.isNotEmpty) 'tags': tags,
        'subCategoryId': subCategoryId,
      };

      debugPrint('📤 addPhysicalProduct → ${ApiConstants.addPhysicalProduct}');
      debugPrint('   body: $body');

      final response = await _client.post(
        ApiConstants.addPhysicalProduct,
        data: body,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final product = response.data['data']['product'];
        debugPrint('✅ Physical product created: ${product['name']} (${product['_id']})');
        return true;
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to create product.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ addPhysicalProduct DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ addPhysicalProduct error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }
}
