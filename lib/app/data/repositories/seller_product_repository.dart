import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SellerProductRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/inventory/low-stock-summary/:storeId ─────────────────────────
  // Store-wide low-stock alert for the seller dashboard — not paginated,
  // returns just the items that need restocking attention.

  Future<({int count, List<Map<String, dynamic>> items})> fetchLowStockSummary({
    required String storeId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.lowStockSummary(storeId),
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (
          count: data['count'] as int? ?? 0,
          items: (data['items'] as List).cast<Map<String, dynamic>>(),
        );
      }

      return (count: 0, items: <Map<String, dynamic>>[]);
    } on DioException catch (e) {
      debugPrint('❌ fetchLowStockSummary DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return (count: 0, items: <Map<String, dynamic>>[]);
    } catch (e) {
      debugPrint('❌ fetchLowStockSummary error: $e');
      return (count: 0, items: <Map<String, dynamic>>[]);
    }
  }

  // ─── GET /api/inventory/getStoreInventory/:storeId ────────────────────────

  Future<({List<Map<String, dynamic>> products, int totalProducts, bool hasMore})>
      fetchStoreInventory({
    required String storeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.getStoreInventory(storeId),
        queryParameters: {'page': page, 'limit': limit},
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final products =
            (data['products'] as List).cast<Map<String, dynamic>>();
        final totalProducts = pagination['totalProducts'] as int? ?? 0;
        final totalPages = pagination['totalPages'] as int? ?? 1;
        return (
          products: products,
          totalProducts: totalProducts,
          hasMore: page < totalPages,
        );
      }

      return (
        products: <Map<String, dynamic>>[],
        totalProducts: 0,
        hasMore: false
      );
    } on DioException catch (e) {
      debugPrint(
          '❌ fetchStoreInventory DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return (
        products: <Map<String, dynamic>>[],
        totalProducts: 0,
        hasMore: false
      );
    } catch (e) {
      debugPrint('❌ fetchStoreInventory error: $e');
      ToastUtil.showToast('Failed to load products. Please try again.');
      return (
        products: <Map<String, dynamic>>[],
        totalProducts: 0,
        hasMore: false
      );
    }
  }

  // ─── POST /api/products/edit-product (digital) ───────────────────────────

  Future<bool> editDigitalProduct({
    required String productId,
    String? variantId,
    required String name,
    required double price,
    required String status,
    String? scheduledAt,
    String? description,
    double? compareAtPrice,
    List<Map<String, dynamic>> files = const [],
    String downloadLimit = 'unlimited',
    int? linkExpiryDays,
    bool pdfStampingEnabled = false,
    String licenseType = 'personal',
    String? buyerDeliveryMessage,
    // Watermarked/trimmed pre-purchase preview, derived server-side from the
    // first uploaded file (see solvexo-api ProductsService.prepareDigitalPreview).
    bool previewEnabled = false,
    List<String> images = const [],
    // Only meaningful when the product's type is 'educational'.
    String? educationLevel,
    String? customLevel,
  }) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        'variantId': variantId,
        'name': name,
        'price': price,
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (images.isNotEmpty) 'images': images,
        if (educationLevel != null) 'educationLevel': educationLevel,
        if (customLevel != null) 'customLevel': customLevel,
        'digital': {
          'files': files,
          'downloadLimit': downloadLimit,
          'linkExpiryDays': linkExpiryDays,
          'pdfStampingEnabled': pdfStampingEnabled,
          'licenseType': licenseType,
          if (buyerDeliveryMessage != null && buyerDeliveryMessage.isNotEmpty)
            'buyerDeliveryMessage': buyerDeliveryMessage,
          'preview': {'enabled': previewEnabled},
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
    String? scheduledAt,
    String? description,
    double? compareAtPrice,
    int? stock,
    bool unlimitedStock = false,
    String? size,
    String? color,
    String? shippingWeight,
    List<String> tags = const [],
    List<String> images = const [],
  }) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        'variantId': variantId,
        'name': name,
        'price': price,
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (stock != null) 'stock': stock,
        'unlimitedStock': unlimitedStock,
        if (size != null && size.isNotEmpty) 'size': size,
        if (color != null && color.isNotEmpty) 'color': color,
        if (shippingWeight != null && shippingWeight.isNotEmpty)
          'shippingWeight': shippingWeight,
        if (tags.isNotEmpty) 'tags': tags,
        if (images.isNotEmpty) 'images': images,
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
    String? scheduledAt,
    String? description,
    double? compareAtPrice,
    List<String> tags = const [],
    List<String> images = const [],
    bool isListedOnSolvexo = false,
    String? subCategoryId,
    // digital object
    List<Map<String, dynamic>> files = const [],
    String downloadLimit = 'unlimited', // "unlimited" | number string
    int? linkExpiryDays,
    bool pdfStampingEnabled = false,
    String licenseType = 'personal',
    String? buyerDeliveryMessage,
    // Watermarked/trimmed pre-purchase preview, derived server-side from the
    // first uploaded file (see solvexo-api ProductsService.prepareDigitalPreview).
    bool previewEnabled = false,
    // Set productType to 'educational' (instead of the default 'digital')
    // plus educationLevel (required) / customLevel (required when 'other')
    // to publish an educational resource — same endpoint, no dedicated one.
    String productType = 'digital',
    String? educationLevel,
    String? customLevel,
  }) async {
    try {
      final body = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        'price': price,
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        'productType': productType,
        'isListedOnSolvexo': isListedOnSolvexo,
        'images': images,
        'subCategoryId': subCategoryId,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (tags.isNotEmpty) 'tags': tags,
        if (educationLevel != null) 'educationLevel': educationLevel,
        if (customLevel != null) 'customLevel': customLevel,
        'digital': {
          'files': files,
          'downloadLimit': downloadLimit,
          'linkExpiryDays': linkExpiryDays,
          'pdfStampingEnabled': pdfStampingEnabled,
          'licenseType': licenseType,
          if (buyerDeliveryMessage != null &&
              buyerDeliveryMessage.isNotEmpty)
            'buyerDeliveryMessage': buyerDeliveryMessage,
          'preview': {'enabled': previewEnabled},
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
    required String status, // "active" | "draft" | "scheduled"
    String? scheduledAt,
    String? description,
    double? compareAtPrice,
    int? stock, // null = unlimited (no stock tracking)
    bool unlimitedStock = false,
    String? size,
    String? color,
    String? shippingWeight,
    List<String> tags = const [],
    List<String> images = const [],
    bool isListedOnSolvexo = false,
    String? subCategoryId,
  }) async {
    try {
      final body = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        'price': price,
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        'isListedOnSolvexo': isListedOnSolvexo,
        'images': images,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (stock != null) 'stock': stock,
        'unlimitedStock': unlimitedStock,
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
