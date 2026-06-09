import 'dart:io';

import 'package:book_store_app/app/data/models/common_models/store_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';

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
    File? logoFile,
    String? categoryId,
    String? description,
    List<String>? productTypes,
  }) async {
    try {
      final dynamic body;

      if (logoFile != null) {
        debugPrint('📤 updateStore (multipart) storeId=$storeId');

        final filename = logoFile.path.split('/').last;
        final ext = filename.split('.').last.toLowerCase();
        final mimeSubtype = ext == 'jpg' ? 'jpeg' : ext;

        // ✅ Use MapEntry list for FormData so we can have repeated keys
        // (required for sending arrays like productTypes in multipart)
        final fields = <MapEntry<String, dynamic>>[
          MapEntry('storeId', storeId),
          MapEntry('name', name),
          MapEntry(
            'logo',
            await MultipartFile.fromFile(
              logoFile.path,
              filename: filename,
              contentType: MediaType('image', mimeSubtype),
            ),
          ),
        ];

        if ((categoryId ?? '').isNotEmpty) {
          fields.add(MapEntry('categoryId', categoryId!));
        }
        if ((description ?? '').isNotEmpty) {
          fields.add(MapEntry('description', description!));
        }
        // ✅ Repeated keys = array on the backend (multer / busboy standard)
        if (productTypes != null && productTypes.isNotEmpty) {
          for (final type in productTypes) {
            fields.add(MapEntry('productTypes[]', type));
          }
        }

        body = FormData.fromMap(Map.fromEntries(fields));
        debugPrint('   FormData fields: ${fields.map((e) => e.key).toList()}');
      } else {
        // ─── JSON branch ───────────────────────────────────────────────────
        debugPrint('📤 updateStore (json) storeId=$storeId');
        body = <String, dynamic>{
          'storeId': storeId,
          'name': name,
          if ((categoryId ?? '').isNotEmpty) 'categoryId': categoryId,
          if ((description ?? '').isNotEmpty) 'description': description,
          if (productTypes != null && productTypes.isNotEmpty)
            'productTypes': productTypes,
        };
        debugPrint('   body: $body');
      }

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

  // ─── POST /api/store/create-store ─────────────────────────────────────────

  Future<StoreModel?> createStore({
    required String name,
    required String sellerType,
    required List<String> productTypes,
    File? logoFile,
    String? categoryId,
    String? description,
  }) async {
    try {
      final dynamic body;

      if (logoFile != null) {
        debugPrint('📤 createStore (multipart) name=$name');

        final filename = logoFile.path.split('/').last;
        final ext = filename.split('.').last.toLowerCase();
        final mimeSubtype = ext == 'jpg' ? 'jpeg' : ext;

        final fields = <MapEntry<String, dynamic>>[
          MapEntry('name', name),
          MapEntry('sellerType', sellerType),
          MapEntry(
            'logo',
            await MultipartFile.fromFile(
              logoFile.path,
              filename: filename,
              contentType: MediaType('image', mimeSubtype),
            ),
          ),
        ];

        if ((categoryId ?? '').isNotEmpty) {
          fields.add(MapEntry('categoryId', categoryId!));
        }
        if ((description ?? '').isNotEmpty) {
          fields.add(MapEntry('description', description!));
        }
        for (final type in productTypes) {
          fields.add(MapEntry('productTypes[]', type));
        }

        body = FormData.fromMap(Map.fromEntries(fields));
      } else {
        debugPrint('📤 createStore (json) name=$name');
        body = <String, dynamic>{
          'name': name,
          'sellerType': sellerType,
          'productTypes': productTypes,
          if ((categoryId ?? '').isNotEmpty) 'categoryId': categoryId,
          if ((description ?? '').isNotEmpty) 'description': description,
        };
        debugPrint('   body: $body');
      }

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
