import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CartRepository {
  final BaseClient _baseClient = BaseClient();

  /// Get cart
  Future<CartResponseModel?> getCart() async {
    try {
      debugPrint('═══════════════════════════════════');
      debugPrint('🛒 GETTING CART');
      debugPrint('═══════════════════════════════════');

      debugPrint('URL: ${ApiConstants.cart}');

      final response = await _baseClient.get(ApiConstants.cart);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      if (response.data['success'] == true) {
        return CartResponseModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ DioException in getCart: ${e.message}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error in getCart: $e');
      rethrow;
    }
  }

  /// Get cart item count
  Future<int> getCartCount() async {
    try {
      final response = await _baseClient.get(ApiConstants.cartCount);

      if (response.data['success'] == true) {
        return response.data['count'] as int;
      }

      return 0;
    } catch (e) {
      debugPrint('❌ Error in getCartCount: $e');
      return 0;
    }
  }

  /// Add item to cart
  Future<CartResponseModel?> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    try {
      debugPrint('🛒 Adding to cart: $productId (qty: $quantity)');

      final response = await _baseClient.post(
        ApiConstants.cartItems,

        data: AddToCartDto(productId: productId, quantity: quantity).toJson(),
      );

      debugPrint('✅ Add to cart response: ${response.data}');

      if (response.data['success'] == true) {
        return CartResponseModel.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ Add to cart error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error in addToCart: $e');
      rethrow;
    }
  }

  /// Update cart item quantity
  Future<CartResponseModel?> updateCartItem({
    required String productId,
    required int quantity,
  }) async {
    try {
      debugPrint('🛒 Updating cart item: $productId to qty: $quantity');

      final response = await _baseClient.put(
        '${ApiConstants.cartItems}/$productId',

        data: UpdateCartItemDto(quantity: quantity).toJson(),
      );

      debugPrint('✅ Update cart response: ${response.data}');

      if (response.data['success'] == true) {
        return CartResponseModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error in updateCartItem: $e');
      rethrow;
    }
  }

  /// Remove item from cart
  Future<CartResponseModel?> removeFromCart(String productId) async {
    try {
      debugPrint('🛒 Removing from cart: $productId');

      final response = await _baseClient.delete(
        '${ApiConstants.cartItems}/$productId',
      );

      debugPrint('✅ Remove from cart response: ${response.data}');

      if (response.data['success'] == true) {
        return CartResponseModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error in removeFromCart: $e');
      rethrow;
    }
  }

  /// Clear entire cart
  Future<bool> clearCart() async {
    try {
      debugPrint('🛒 Clearing cart');

      final response = await _baseClient.delete(ApiConstants.cart);

      debugPrint('✅ Clear cart response: ${response.data}');

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ Error in clearCart: $e');
      return false;
    }
  }

  /// Validate cart before checkout
  Future<CartValidationResponse?> validateCart() async {
    try {
      debugPrint('🛒 Validating cart');

      final response = await _baseClient.get(ApiConstants.cartValidate);

      debugPrint('✅ Validate cart response: ${response.data}');

      if (response.data['success'] == true) {
        return CartValidationResponse.fromJson(response.data);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error in validateCart: $e');
      rethrow;
    }
  }

  /// Sync cart with backend prices
  Future<CartResponseModel?> syncCart() async {
    try {
      debugPrint('🛒 Syncing cart');

      final response = await _baseClient.post(ApiConstants.cartSync);

      debugPrint('✅ Sync cart response: ${response.data}');

      if (response.data['success'] == true) {
        return CartResponseModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error in syncCart: $e');
      rethrow;
    }
  }
}
