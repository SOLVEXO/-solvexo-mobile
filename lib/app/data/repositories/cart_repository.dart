import 'package:book_store_app/config/app_config.dart';
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
      // GET /api/cart/unified: every store's lines (each with storeId and
      // type). get-cart without ?storeId returns an EMPTY cart (5adba44).
      debugPrint('🛒 GETTING CART — ${ApiConstants.cartUnified}');
      debugPrint('═══════════════════════════════════');

      final response = await _baseClient.get(
        ApiConstants.cartUnified,
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
  // GET /api/cart/unified → data.totalItems (there is no /cart/count endpoint)

  Future<int> getCartCount() async {
    try {
      final response = await _baseClient.get(
        ApiConstants.cartUnified,
        requiresAuth: true,
      );
      return parseTotalItems(response.data);
    } catch (e) {
      debugPrint('❌ Error in getCartCount: $e');
      return 0;
    }
  }

  /// `totalItems` of a `/cart/unified` response body, 0 when absent.
  static int parseTotalItems(dynamic body) {
    final data = body is Map ? body['data'] : null;
    final total = data is Map ? data['totalItems'] : null;
    return total is num ? total.toInt() : 0;
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
  // Body: { storeId, productId, productVariantId, action: "increase" | "decrease" }

  Future<CartItem?> updateCartItem({
    required String? storeId,
    required String productId,
    required String productVariantId,
    required String action,
  }) async {
    try {
      debugPrint('🛒 updateCartItem: $productId | $productVariantId | $action');

      final response = await _baseClient.post(
        ApiConstants.updateCartQuantity,
        data: {
          if (storeId != null) 'storeId': storeId,
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
  // POST /api/cart/remove-cart-item
  // Body: { storeId, productId, productVariantId }

  Future<List<CartItem>?> removeFromCart(
    String productId,
    String productVariantId, {
    String? storeId,
  }) async {
    try {
      debugPrint('🛒 removeFromCart: $productId | $productVariantId');

      final response = await _baseClient.post(
        ApiConstants.removeCartItem,
        data: {
          if (storeId != null) 'storeId': storeId,
          'productId': productId,
          'productVariantId': productVariantId,
        },
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

  // ─── Merge guest cart into account cart ───────────────────────────────────
  // No dedicated backend endpoint for this — `addToCart` already sums
  // quantities when a line already exists in the account cart (see
  // `CartService.addToCart`), so replaying each local guest line through the
  // normal endpoint achieves the same "sum on conflict" merge with no new
  // backend surface. Called once, right after login/signup succeeds.
  Future<void> mergeGuestCartIntoAccount() async {
    final localItems = await AppPreferences.getGuestCartItems();
    if (localItems.isEmpty) return;

    for (final json in localItems) {
      final productId = json['productId'] as String? ?? '';
      final productVariantId = json['productVariantId'] as String? ?? '';
      final quantity = (json['quantity'] as num?)?.toInt() ?? 1;
      if (productId.isEmpty || productVariantId.isEmpty) continue;
      // Digital items cannot be bought yet: don't carry them into the account cart.
      if (AppFeatures.blocksPurchase(json['productType'] as String?)) continue;
      try {
        await addToCart(
          productId: productId,
          productVariantId: productVariantId,
          quantity: quantity,
        );
      } catch (e) {
        debugPrint('❌ Guest cart merge failed for $productId: $e');
      }
    }

    await AppPreferences.clearGuestCart();
  }

  // ─── Clear cart ────────────────────────────────────────────────────────────
  // POST /api/cart/clear-all (every store's cart). clear-cart needs a
  // storeId (400 without one).

  Future<bool> clearCart() async {
    try {
      debugPrint('🛒 Clearing cart');
      final response = await _baseClient.post(ApiConstants.clearAllCarts);
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
