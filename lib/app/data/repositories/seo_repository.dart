import 'package:book_store_app/app/data/models/seo/seo_dashboard_model.dart';
import 'package:book_store_app/app/data/models/seo/seo_meta_model.dart';
import 'package:book_store_app/app/data/models/seo/seo_product_list_item_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Seller-side on-page SEO management — store/product meta, checklist, bulk
/// template apply, CSV export (`solvexo-api`'s `src/seo/seller/*` routes).
/// Every seller route is wrapped in a `{ success, data }` envelope.
class SeoRepository {
  final BaseClient _client = BaseClient();

  Map<String, dynamic> _metaFieldsToJson({
    String? metaTitle,
    String? metaDescription,
    String? ogImage,
    String? ogTitle,
    String? ogDescription,
    String? twitterCard,
    String? canonicalUrlOverride,
    bool? noindex,
    List<String>? keywords,
  }) {
    final data = <String, dynamic>{};
    if (metaTitle != null) data['metaTitle'] = metaTitle;
    if (metaDescription != null) data['metaDescription'] = metaDescription;
    if (ogImage != null) data['ogImage'] = ogImage;
    if (ogTitle != null) data['ogTitle'] = ogTitle;
    if (ogDescription != null) data['ogDescription'] = ogDescription;
    if (twitterCard != null) data['twitterCard'] = twitterCard;
    if (canonicalUrlOverride != null) data['canonicalUrlOverride'] = canonicalUrlOverride;
    if (noindex != null) data['noindex'] = noindex;
    if (keywords != null) data['keywords'] = keywords;
    return data;
  }

  Future<SeoDashboardModel?> getDashboard(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.seoDashboard(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return SeoDashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getDashboard error: $e');
      return null;
    }
  }

  Future<SeoMetaModel?> getStoreSeo(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.seoStoreMeta(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return SeoMetaModel.fromJson(response.data['data'] as Map<String, dynamic>?);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getStoreSeo error: $e');
      return null;
    }
  }

  Future<SeoMetaModel?> updateStoreSeo(
    String storeId, {
    String? metaTitle,
    String? metaDescription,
    String? ogImage,
    String? ogTitle,
    String? ogDescription,
    String? twitterCard,
    String? canonicalUrlOverride,
    bool? noindex,
    List<String>? keywords,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.seoStoreMeta(storeId),
        data: _metaFieldsToJson(
          metaTitle: metaTitle,
          metaDescription: metaDescription,
          ogImage: ogImage,
          ogTitle: ogTitle,
          ogDescription: ogDescription,
          twitterCard: twitterCard,
          canonicalUrlOverride: canonicalUrlOverride,
          noindex: noindex,
          keywords: keywords,
        ),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast('Store SEO updated');
        return SeoMetaModel.fromJson(response.data['data'] as Map<String, dynamic>?);
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to update store SEO.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateStoreSeo error: $e');
      ToastUtil.showToast('Failed to update store SEO.');
      return null;
    }
  }

  Future<List<SeoChecklistItemModel>> getChecklist(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.seoStoreChecklist(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return (response.data['data'] as List? ?? [])
            .map((e) => SeoChecklistItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getChecklist error: $e');
      return [];
    }
  }

  Future<List<SeoChecklistItemModel>?> updateChecklistItem(
    String storeId, {
    required String key,
    required bool done,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.seoStoreChecklist(storeId),
        data: {'key': key, 'done': done},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return (response.data['data'] as List? ?? [])
            .map((e) => SeoChecklistItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to update checklist.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateChecklistItem error: $e');
      ToastUtil.showToast('Failed to update checklist.');
      return null;
    }
  }

  /// Paginated product SEO list — `data.items` shaped per
  /// `SeoProductListItemModel`, `data.pagination` gives page/limit/total/pages.
  Future<({List<SeoProductListItemModel> items, int total, int pages})> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.seoProducts(storeId),
        requiresAuth: true,
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        final pagination = data['pagination'] as Map<String, dynamic>? ?? const {};
        return (
          items: (data['items'] as List? ?? [])
              .map((e) => SeoProductListItemModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: pagination['total'] as int? ?? 0,
          pages: pagination['pages'] as int? ?? 1,
        );
      }
      return (items: <SeoProductListItemModel>[], total: 0, pages: 0);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (items: <SeoProductListItemModel>[], total: 0, pages: 0);
    } catch (e) {
      debugPrint('❌ getProducts error: $e');
      return (items: <SeoProductListItemModel>[], total: 0, pages: 0);
    }
  }

  Future<SeoMetaModel?> getProductSeo(String storeId, String productId) async {
    try {
      final response = await _client.get(ApiConstants.seoProductById(storeId, productId), requiresAuth: true);
      if (response.data['success'] == true) {
        return SeoMetaModel.fromJson(response.data['data'] as Map<String, dynamic>?);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getProductSeo error: $e');
      return null;
    }
  }

  Future<SeoMetaModel?> updateProductSeo(
    String storeId,
    String productId, {
    String? metaTitle,
    String? metaDescription,
    String? ogImage,
    String? ogTitle,
    String? ogDescription,
    String? twitterCard,
    String? canonicalUrlOverride,
    bool? noindex,
    List<String>? keywords,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.seoProductById(storeId, productId),
        data: _metaFieldsToJson(
          metaTitle: metaTitle,
          metaDescription: metaDescription,
          ogImage: ogImage,
          ogTitle: ogTitle,
          ogDescription: ogDescription,
          twitterCard: twitterCard,
          canonicalUrlOverride: canonicalUrlOverride,
          noindex: noindex,
          keywords: keywords,
        ),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast('Product SEO updated');
        return SeoMetaModel.fromJson(response.data['data'] as Map<String, dynamic>?);
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to update product SEO.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateProductSeo error: $e');
      ToastUtil.showToast('Failed to update product SEO.');
      return null;
    }
  }

  /// Applies a title/description template across products (optionally only
  /// those missing a meta title). Returns the number of products updated,
  /// or null on failure.
  Future<int?> bulkApplyTemplate(
    String storeId, {
    String? titleTemplate,
    String? descriptionTemplate,
    String? categoryId,
    bool? onlyMissing,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (titleTemplate != null && titleTemplate.isNotEmpty) data['titleTemplate'] = titleTemplate;
      if (descriptionTemplate != null && descriptionTemplate.isNotEmpty) {
        data['descriptionTemplate'] = descriptionTemplate;
      }
      if (categoryId != null && categoryId.isNotEmpty) data['categoryId'] = categoryId;
      if (onlyMissing != null) data['onlyMissing'] = onlyMissing;

      final response = await _client.post(
        ApiConstants.seoProductsBulkApplyTemplate(storeId),
        data: data,
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final updated = (response.data['data'] as Map<String, dynamic>?)?['updated'] as int? ?? 0;
        ToastUtil.showToast('Updated SEO for $updated product(s)');
        return updated;
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to apply template.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ bulkApplyTemplate error: $e');
      ToastUtil.showToast('Failed to apply template.');
      return null;
    }
  }

  /// Downloads the product SEO CSV as raw bytes (not JSON-enveloped — this
  /// handler streams `text/csv` directly).
  Future<List<int>?> exportProductsCsv(String storeId) async {
    try {
      final response = await _client.get(
        ApiConstants.seoProductsExport(storeId),
        requiresAuth: true,
        responseType: ResponseType.bytes,
      );
      return response.data as List<int>;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ exportProductsCsv error: $e');
      ToastUtil.showToast('Failed to export CSV.');
      return null;
    }
  }
}
