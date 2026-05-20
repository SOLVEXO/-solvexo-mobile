import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CartRepository {
  final BaseClient _baseClient = BaseClient();

  // ─── Get cart ──────────────────────────────────────────────────────────────
  // GET /api/cart/get-cart

  Future<CartResponseModel?> getCart() async {
    try {
      debugPrint('═══════════════════════════════════');
      debugPrint('🛒 GETTING CART — ${ApiConstants.getCart}');
      debugPrint('═══════════════════════════════════');

      final response = await _baseClient.get(
        ApiConstants.getCart,
        requiresAuth: true,
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final data = response.data?['data'];
      if (data != null) {
        return CartResponseModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ DioException in getCart: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error in getCart: $e');
      rethrow;
    }
  }

  // ─── Get cart count ────────────────────────────────────────────────────────

  Future<int> getCartCount() async {
    try {
      final response = await _baseClient.get(ApiConstants.cartCount);
      if (response.data['success'] == true) {
        return (response.data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('❌ Error in getCartCount: $e');
      return 0;
    }
  }

  // ─── Add to cart ───────────────────────────────────────────────────────────
  // POST /api/cart/add-to-cart
  // Body: { productId, productVariantId, quantity }

  Future<CartResponseModel?> addToCart({
    required String productId,
    required String productVariantId,
    int quantity = 1,
  }) async {
    try {
      debugPrint('═══════════════════════════════════');
      debugPrint('🛒 ADD TO CART');
      debugPrint('ProductId:  $productId');
      debugPrint('VariantId:  $productVariantId');
      debugPrint('Quantity:   $quantity');
      debugPrint('URL:        ${ApiConstants.addToCart}');
      debugPrint('═══════════════════════════════════');

      final userId = await AppPreferences.getUserId();
      final token = await AppPreferences.getAccessTokenAsync();
      debugPrint('UserId: $userId | Token: $token');

      final response = await _baseClient.post(
        ApiConstants.addToCart,
        data: AddToCartDto(
          productId: productId,
          productVariantId: productVariantId,
          quantity: quantity,
        ).toJson(),
      );

      debugPrint('✅ Status: ${response.statusCode}');
      debugPrint('✅ Response: ${response.data}');

      final data = response.data?['data'];
      if (data != null) {
        return CartResponseModel.fromJson(data as Map<String, dynamic>);
      }
      debugPrint('❌ No data key in add-to-cart response');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Add to cart DioError: ${e.response?.statusCode}');
      debugPrint('❌ Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error in addToCart: $e');
      rethrow;
    }
  }

  // ─── Update cart quantity ──────────────────────────────────────────────────
  // POST /api/cart/update-cart-quantity
  // Body: { productId, productVariantId, action: "increase" | "decrease" }

  Future<CartItem?> updateCartItem({
    required String productId,
    required String productVariantId,
    required String action,
  }) async {
    try {
      debugPrint('🛒 updateCartItem: $productId | $productVariantId | $action');

      final response = await _baseClient.post(
        ApiConstants.updateCartQuantity,
        data: {
          'productId': productId,
          'productVariantId': productVariantId,
          'action': action,
        },
      );

      debugPrint('✅ Update cart response: ${response.data}');

      // Response: { message, data: { productId, productVariantId, name,
      //                              quantity, price, images[] } }
      final data = response.data?['data'];
      if (data != null && data is Map<String, dynamic>) {
        return CartItem.fromBackendJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error in updateCartItem: $e');
      rethrow;
    }
  }
  // ─── Remove cart item ──────────────────────────────────────────────────────
  // DELETE /api/cart/remove-cart-item
  // Body: { productId, productVariantId }

  Future<List<CartItem>?> removeFromCart(
    String productId,
    String productVariantId,
  ) async {
    try {
      debugPrint('🛒 removeFromCart: $productId | $productVariantId');

      final response = await _baseClient.post(
        ApiConstants.removeCartItem,
        data: {'productId': productId, 'productVariantId': productVariantId},
      );

      debugPrint('✅ Remove cart response: ${response.data}');

      final data = response.data?['data'];

      if (data is List) {
        // Parse the remaining items list directly
        return data
            .map(
              (item) => CartItem.fromBackendJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error in removeFromCart: $e');
      rethrow;
    }
  }

  // ─── Clear cart ────────────────────────────────────────────────────────────
  // DELETE /api/cart

  Future<bool> clearCart() async {
    try {
      debugPrint('🛒 Clearing cart');
      final response = await _baseClient.post(ApiConstants.clearCart);
      debugPrint('✅ Clear cart response: ${response.data}');
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('❌ Error in clearCart: $e');
      return false;
    }
  }

  // ─── Validate cart ─────────────────────────────────────────────────────────

  // Future<CartValidationResponse?> validateCart() async {
  //   try {
  //     debugPrint('🛒 Validating cart');
  //     final response = await _baseClient.get(ApiConstants.cartValidate);
  //     debugPrint('✅ Validate cart response: ${response.data}');
  //     if (response.data['success'] == true) {
  //       return CartValidationResponse.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );
  //     }
  //     return null;
  //   } catch (e) {
  //     debugPrint('❌ Error in validateCart: $e');
  //     rethrow;
  //   }
  // }

  // ─── Sync cart ─────────────────────────────────────────────────────────────

  // Future<CartResponseModel?> syncCart() async {
  //   try {
  //     debugPrint('🛒 Syncing cart');
  //     final response = await _baseClient.post(ApiConstants.cartSync);
  //     debugPrint('✅ Sync cart response: ${response.data}');
  //     final data = response.data?['data'];
  //     if (data != null) {
  //       return CartResponseModel.fromJson(data as Map<String, dynamic>);
  //     }
  //     return null;
  //   } catch (e) {
  //     debugPrint('❌ Error in syncCart: $e');
  //     rethrow;
  //   }
  // }
}
