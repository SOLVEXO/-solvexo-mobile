import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SellerProductRepository {
  SellerProductRepository({BaseClient? client}) : _client = client ?? BaseClient();

  final BaseClient _client;

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

  Future<
      ({
        List<Map<String, dynamic>> products,
        int totalProducts,
        bool hasMore,
        Map<String, int> statusCounts,
        bool failed,
      })> fetchStoreInventory({
    required String storeId,
    int page = 1,
    int limit = 20,
    // Raw product status (verified: draft filters to drafts, active to
    // live): active | pending_review | rejected | draft | inactive | scheduled.
    String? status,
    // Server search is `q` (verified; `search` is ignored).
    String? query,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.getStoreInventory(storeId),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final products =
            (data['products'] as List).cast<Map<String, dynamic>>();
        final totalProducts = pagination['totalProducts'] as int? ?? 0;
        final totalPages = pagination['totalPages'] as int? ?? 1;
        final stats = data['stats'] is Map ? data['stats'] as Map : const {};
        final rawCounts = stats['statusCounts'] is Map ? stats['statusCounts'] as Map : const {};
        return (
          products: products,
          totalProducts: (stats['totalProducts'] as num?)?.toInt() ?? totalProducts,
          hasMore: page < totalPages,
          statusCounts: <String, int>{
            for (final e in rawCounts.entries)
              if (e.value is num) '${e.key}': (e.value as num).toInt(),
          },
          failed: false,
        );
      }

      return (
        products: <Map<String, dynamic>>[],
        totalProducts: 0,
        hasMore: false,
        statusCounts: <String, int>{},
        failed: true,
      );
    } on DioException catch (e) {
      debugPrint(
          '❌ fetchStoreInventory DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return (
        products: <Map<String, dynamic>>[],
        totalProducts: 0,
        hasMore: false,
        statusCounts: <String, int>{},
        failed: true,
      );
    } catch (e) {
      debugPrint('❌ fetchStoreInventory error: $e');
      ToastUtil.showToast('Failed to load products. Please try again.');
      return (
        products: <Map<String, dynamic>>[],
        totalProducts: 0,
        hasMore: false,
        statusCounts: <String, int>{},
        failed: true,
      );
    }
  }

  // ─── Products list actions (checklist #11; verified on test drafts) ────────

  /// POST /api/products/duplicate/:id -> 201 "Draft copy created",
  /// data {productId, slug, name, status:'draft'}.
  Future<({bool ok, String? message})> duplicateProduct(String productId) async {
    try {
      final res = await _client.post(ApiConstants.duplicateProduct(productId), data: const {}, requiresAuth: true);
      final body = res.data;
      final ok = body is Map && body['success'] == true;
      return (ok: ok, message: body is Map ? ApiError.msg(body['message']) : null);
    } on DioException catch (e) {
      return (ok: false, message: ApiError.fromDio(e) ?? 'Could not duplicate the product.');
    }
  }

  /// PATCH /api/products/bulk-status {ids, active} -> {updated:[...],
  /// skipped:[{id, name, reason}], changedMeanwhile}. A draft is skipped with
  /// "Only a live or scheduled product can be deactivated."
  Future<({int updated, List<String> skipped, String? message})> setProductsActive(
    List<String> ids, {
    required bool active,
  }) async {
    try {
      final res = await _client.patch(
        ApiConstants.productsBulkStatus,
        data: {'ids': ids, 'active': active},
        requiresAuth: true,
      );
      final body = res.data is Map ? res.data as Map : const {};
      final data = body['data'] is Map ? body['data'] as Map : const {};
      final updated = data['updated'];
      final skipped = data['skipped'] is List ? data['skipped'] as List : const [];
      return (
        updated: updated is List ? updated.length : (updated is num ? updated.toInt() : 0),
        skipped: [
          for (final s in skipped)
            if (s is Map) '${s['name'] ?? s['id']}: ${s['reason'] ?? 'skipped'}',
        ],
        message: ApiError.msg(body['message']),
      );
    } on DioException catch (e) {
      return (updated: 0, skipped: const <String>[], message: ApiError.fromDio(e) ?? 'Could not change the products.');
    }
  }

  /// Digital inline price: POST edit-product {productId, price} (no status
  /// -> the status stays as it is; verified on a draft).
  Future<({bool ok, String? message})> setDigitalPrice(String productId, double price) async {
    try {
      final res = await _client.post(ApiConstants.editProduct, data: {'productId': productId, 'price': price}, requiresAuth: true);
      final body = res.data;
      return (ok: body is Map && body['success'] == true, message: body is Map ? ApiError.msg(body['message']) : null);
    } on DioException catch (e) {
      return (ok: false, message: ApiError.fromDio(e) ?? 'Could not change the price.');
    }
  }

  /// Physical inline price: PATCH /api/products/:id/variants/:variantId
  /// {price} (digital -> 400 "Only physical products support variants").
  Future<({bool ok, String? message})> setVariantPrice(String productId, String variantId, double price) async {
    try {
      final res = await _client.patch(ApiConstants.productVariant(productId, variantId), data: {'price': price}, requiresAuth: true);
      final body = res.data;
      return (ok: body is Map && body['success'] == true, message: body is Map ? ApiError.msg(body['message']) : null);
    } on DioException catch (e) {
      return (ok: false, message: ApiError.fromDio(e) ?? 'Could not change the price.');
    }
  }

  /// PATCH /api/products/stock/bulk {storeId, updates:[{variantId, stock}]}
  /// -> {updated: 1, skipped: []}; stock 0..1,000,000 whole numbers.
  Future<({bool ok, String? message})> setVariantStock(String storeId, String variantId, int stock) async {
    try {
      final res = await _client.patch(
        ApiConstants.productsStockBulk,
        data: {
          'storeId': storeId,
          'updates': [
            {'variantId': variantId, 'stock': stock},
          ],
        },
        requiresAuth: true,
      );
      final body = res.data;
      return (ok: body is Map && body['success'] == true, message: body is Map ? ApiError.msg(body['message']) : null);
    } on DioException catch (e) {
      return (ok: false, message: ApiError.fromDio(e) ?? 'Could not change the stock.');
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
    String? coverStyle,
    String? classFrom,
    String? classTo,
      Map<String, dynamic>? sampleFile,
}) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        'variantId': variantId,
        'name': name,
        if (coverStyle != null) 'coverStyle': coverStyle,
        if (classFrom != null) 'classFrom': classFrom,
        if (classTo != null) 'classTo': classTo,
        'price': price,
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
        if (images.isNotEmpty) 'images': images,
        'digital': {
          'files': files,
          'downloadLimit': downloadLimit,
          'linkExpiryDays': linkExpiryDays,
          'pdfStampingEnabled': pdfStampingEnabled,
          'licenseType': licenseType,
          if (buyerDeliveryMessage != null && buyerDeliveryMessage.isNotEmpty)
            'buyerDeliveryMessage': buyerDeliveryMessage,
          'preview': {'enabled': previewEnabled},
          if (sampleFile != null) 'sampleFile': sampleFile,
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
        ApiError.msg(response.data['message']) ?? 'Failed to update product.',
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
        ApiError.msg(response.data['message']) ?? 'Failed to update product.',
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
    // Only 'digital': the 'educational' type is retired (API answers 400).
    String productType = 'digital',
    String? coverStyle,
    String? classFrom,
    String? classTo,
      Map<String, dynamic>? sampleFile,
}) async {
    try {
      final body = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        if (coverStyle != null) 'coverStyle': coverStyle,
        if (classFrom != null) 'classFrom': classFrom,
        if (classTo != null) 'classTo': classTo,
        'price': price,
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        'productType': productType,
        'isListedOnEdudeen': isListedOnSolvexo,
        'images': images,
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
          'preview': {'enabled': previewEnabled},
          if (sampleFile != null) 'sampleFile': sampleFile,
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
        ApiError.msg(response.data['message']) ?? 'Failed to create product.',
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
    required String status, // "active" | "draft" | "scheduled"
    required List<Map<String, dynamic>> variants,
    String? scheduledAt,
    String? description,
    List<String> tags = const [],
    List<String> images = const [],
    bool isListedOnSolvexo = false,
    String? subCategoryId,
    String? coverStyle,
    String? classFrom,
    String? classTo,
  }) async {
    try {
      final body = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        if (coverStyle != null) 'coverStyle': coverStyle,
        if (classFrom != null) 'classFrom': classFrom,
        if (classTo != null) 'classTo': classTo,
        'status': status,
        'variants': variants,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        'isListedOnEdudeen': isListedOnSolvexo,
        'images': images,
        if (description != null && description.isNotEmpty)
          'description': description,
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
        ApiError.msg(response.data['message']) ?? 'Failed to create product.',
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

  // ─── POST /api/products/edit-product (product-level fields only) ─────────

  Future<bool> editProductFields({
    required String productId,
    required String name,
    required String status,
    String? scheduledAt,
    String? description,
    List<String> tags = const [],
    List<String> images = const [],
    String? subCategoryId,
    String? coverStyle,
    String? classFrom,
    String? classTo,
  }) async {
    try {
      final body = <String, dynamic>{
        'productId': productId,
        'name': name,
        if (coverStyle != null) 'coverStyle': coverStyle,
        if (classFrom != null) 'classFrom': classFrom,
        if (classTo != null) 'classTo': classTo,
        'status': status,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (images.isNotEmpty) 'images': images,
        if (tags.isNotEmpty) 'tags': tags,
        if (subCategoryId != null) 'subCategoryId': subCategoryId,
      };

      debugPrint('📤 editProductFields → ${ApiConstants.editProduct}');
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
        ApiError.msg(response.data['message']) ?? 'Failed to update product.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ editProductFields DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ editProductFields error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── GET /api/products/get-my-product/:productId ──────────────────────────
  // Returns the full { product, variants, defaultVariant } shape — used by
  // the Edit Product screen to load every existing variant, not just the
  // single flattened one the inventory list returns.

  Future<({Map<String, dynamic>? product, List<Map<String, dynamic>> variants})>
      getMyProduct(String productId) async {
    try {
      final response = await _client.get(
        ApiConstants.getMyProduct(productId),
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (
          product: data['product'] as Map<String, dynamic>?,
          variants: (data['variants'] as List? ?? [])
              .cast<Map<String, dynamic>>(),
        );
      }
      return (product: null, variants: <Map<String, dynamic>>[]);
    } on DioException catch (e) {
      debugPrint('❌ getMyProduct DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return (product: null, variants: <Map<String, dynamic>>[]);
    } catch (e) {
      debugPrint('❌ getMyProduct error: $e');
      return (product: null, variants: <Map<String, dynamic>>[]);
    }
  }

  // ─── POST /api/products/:productId/variants ───────────────────────────────

  Future<bool> addVariant({
    required String productId,
    required Map<String, dynamic> variant,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.productVariants(productId),
        data: variant,
        requiresAuth: true,
      );
      if (response.data['success'] == true) return true;
      ToastUtil.showToast(
        ApiError.msg(response.data['message']) ?? 'Failed to add variant.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ addVariant DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ addVariant error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── PATCH /api/products/:productId/variants/:variantId ───────────────────

  Future<bool> updateVariant({
    required String productId,
    required String variantId,
    required Map<String, dynamic> variant,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.productVariant(productId, variantId),
        data: variant,
        requiresAuth: true,
      );
      if (response.data['success'] == true) return true;
      ToastUtil.showToast(
        ApiError.msg(response.data['message']) ?? 'Failed to update variant.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ updateVariant DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ updateVariant error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── DELETE /api/products/:productId/variants/:variantId ──────────────────

  Future<bool> deleteVariant({
    required String productId,
    required String variantId,
  }) async {
    try {
      final response = await _client.delete(
        ApiConstants.productVariant(productId, variantId),
        requiresAuth: true,
      );
      if (response.data['success'] == true) return true;
      ToastUtil.showToast(
        ApiError.msg(response.data['message']) ?? 'Failed to delete variant.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ deleteVariant DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deleteVariant error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }

  // ─── DELETE /api/products/delete-product/:productId ───────────────────────

  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _client.delete(
        ApiConstants.deleteProduct(productId),
        requiresAuth: true,
      );
      if (response.data['success'] == true) return true;
      ToastUtil.showToast(
        ApiError.msg(response.data['message']) ?? 'Failed to delete product.',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ deleteProduct DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ deleteProduct error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return false;
    }
  }
}
