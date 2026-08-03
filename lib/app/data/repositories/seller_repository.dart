import 'package:book_store_app/app/data/models/common_models/store_model.dart';
import 'package:book_store_app/app/data/models/store/store_announcement_bar_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SellerRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/store/my-stores ─────────────────────────────────────────────

  Future<List<StoreModel>> getMyStores() async {
    try {
      debugPrint('📤 getMyStores → ${ApiConstants.myStores}');
      final response = await _client.get(
        ApiConstants.myStores,
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final list = response.data['data'] as List<dynamic>;
        return list
            .map((e) => StoreModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getMyStores error: $e');
      return [];
    }
  }

  // ─── GET /api/store/getStoreById/:id ──────────────────────────────────────

  Future<StoreModel?> getStoreById(String id) async {
    try {
      final response = await _client.get(
        ApiConstants.getStoreById(id),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return StoreModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getStoreById error: $e');
      return null;
    }
  }

  // ─── POST /api/store/update-store ─────────────────────────────────────────

  Future<StoreModel?> updateStore({
    required String storeId,
    required String name,
    String? logoUrl,
    String? coverImageUrl,
    String? categoryId,
    String? description,
    List<String>? productTypes,
  }) async {
    try {
      debugPrint('📤 updateStore storeId=$storeId');
      final body = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        if ((logoUrl ?? '').isNotEmpty) 'logo': logoUrl,
        if ((coverImageUrl ?? '').isNotEmpty) 'coverImage': coverImageUrl,
        if ((categoryId ?? '').isNotEmpty) 'categoryId': categoryId,
        if ((description ?? '').isNotEmpty) 'description': description,
        if (productTypes != null && productTypes.isNotEmpty)
          'productTypes': productTypes,
      };
      debugPrint('   body: $body');

      final response = await _client.post(
        ApiConstants.updateStore,
        data: body,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final store = StoreModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        debugPrint('✅ Store updated: ${store.name} | logo: ${store.logo}');
        return store;
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to update store.',
      );
      return null;
    } on DioException catch (e) {
      debugPrint('❌ DioException updateStore: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateStore error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return null;
    }
  }

  // ─── PATCH /api/store/:storeId/pinned-products ─────────────────────────────

  Future<List<String>?> updatePinnedProducts(String storeId, List<String> productIds) async {
    try {
      final response = await _client.patch(
        ApiConstants.storePinnedProducts(storeId),
        data: {'productIds': productIds},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (data['pinnedProductIds'] as List?)?.cast<String>() ?? const [];
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to update pinned products.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updatePinnedProducts error: $e');
      return null;
    }
  }

  // ─── PATCH /api/store/:storeId/announcement ────────────────────────────────

  Future<StoreAnnouncementBarModel?> updateAnnouncementBar(String storeId, StoreAnnouncementBarModel bar) async {
    try {
      final response = await _client.patch(
        ApiConstants.storeAnnouncement(storeId),
        data: bar.toJson(),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return StoreAnnouncementBarModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to update announcement bar.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updateAnnouncementBar error: $e');
      return null;
    }
  }

  // ─── POST /api/store/create-store ─────────────────────────────────────────

  Future<StoreModel?> createStore({
    required String name,
    required String sellerType,
    required List<String> productTypes,
    String? logoUrl,
    String? categoryId,
    String? description,
  }) async {
    try {
      debugPrint('📤 createStore name=$name');
      final body = <String, dynamic>{
        'name': name,
        'sellerType': sellerType,
        'productTypes': productTypes,
        if ((logoUrl ?? '').isNotEmpty) 'logo': logoUrl,
        if ((categoryId ?? '').isNotEmpty) 'categoryId': categoryId,
        if ((description ?? '').isNotEmpty) 'description': description,
      };
      debugPrint('   body: $body');

      final response = await _client.post(
        ApiConstants.createStore,
        data: body,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final store = StoreModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
        debugPrint('✅ Store created: ${store.name} (${store.id})');
        return store;
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to create store.',
      );
      return null;
    } on DioException catch (e) {
      debugPrint('❌ DioException createStore: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ createStore error: $e');
      ToastUtil.showToast('Something went wrong. Please try again.');
      return null;
    }
  }
}
