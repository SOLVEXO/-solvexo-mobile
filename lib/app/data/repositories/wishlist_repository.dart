import 'package:book_store_app/app/modules/wishlist/model/wishlist_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class WishlistRepository {
  final BaseClient _baseClient = BaseClient();

  Future<List<WishlistItem>> getWishlist() async {
    try {
      debugPrint('❤️ GET ${ApiConstants.getWishlist}');

      final response = await _baseClient.get(
        ApiConstants.getWishlist,
        requiresAuth: true,
      );

      debugPrint('✅ getWishlist: ${response.data}');

      final data = response.data?['data'];
      if (data is List) {
        return data
            .map((e) => WishlistItem.fromListJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getWishlist error: $e');
      return [];
    }
  }

  Future<WishlistItem?> getWishlistItem({
    required String productId,
    required String productVariantId,
  }) async {
    try {
      debugPrint('❤️ GET ${ApiConstants.getWishlistItem}');

      final response = await _baseClient.get(
        ApiConstants.getWishlistItem,
        queryParameters: {
          'productId': productId,
          'productVariantId': productVariantId,
        },
        requiresAuth: true,
      );

      debugPrint('✅ getWishlistItem: ${response.data}');

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return WishlistItem.fromDetailJson(data);
      }
      return null;
    } on DioException catch (e) {
      // 404 means item is not in wishlist — not an error
      if (e.response?.statusCode == 404) return null;
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getWishlistItem error: $e');
      return null;
    }
  }

  Future<WishlistItem?> addToWishlist({
    required String productId,
    required String productVariantId,
  }) async {
    try {
      debugPrint('❤️ POST ${ApiConstants.addToWishlist}');
      debugPrint('Body: productId=$productId | variantId=$productVariantId');

      final response = await _baseClient.post(
        ApiConstants.addToWishlist,
        data: AddToWishlistDto(
          productId: productId,
          productVariantId: productVariantId,
        ).toJson(),
      );

      debugPrint('✅ addToWishlist: ${response.data}');

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return WishlistItem.fromDetailJson(data);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ addToWishlist error: $e');
      return null;
    }
  }

  Future<bool> clearWishList() async {
    try {
      debugPrint('🛒 Clearing WishList');
      final response = await _baseClient.post(ApiConstants.clearWishList);
      debugPrint('✅ Clear WishList response: ${response.data}');
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Error in clearWishList: $e');
      return false;
    }
  }

  Future<bool> removeFromWishlist({required String wishlistId}) async {
    try {
      debugPrint('❤️ DELETE ${ApiConstants.removeFromWishlist}');
      debugPrint('wishlistId: $wishlistId');

      final response = await _baseClient.post(
        ApiConstants.removeFromWishlist,
        data: RemoveFromWishlistDto(wishlistId: wishlistId).toJson(),
      );

      debugPrint('✅ removeFromWishlist: ${response.data}');

      return response.statusCode == 200;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ removeFromWishlist error: $e');
      return false;
    }
  }
}
