import 'package:book_store_app/app/modules/checkout/models/create_checkout_response.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';

class CheckoutRepository {
  final BaseClient _client = BaseClient();

  /// POST /api/checkout/create-checkout
  /// No request body — the server reads the cart from the auth token.
  Future<CreateCheckoutResponse?> createCheckout() async {
    try {
      final response = await _client.post(
        ApiConstants.createCheckout,
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        return CreateCheckoutResponse.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to create checkout',
      );
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      ToastUtil.showToast('Failed to create checkout');
      return null;
    }
  }

  /// POST /api/checkout/addShippingInCheckout
  /// Called whenever the user selects a shipping zone on the checkout screen.
  Future<AddShippingResult?> addShippingToCheckout({
    required String checkoutId,
    required String shippingZoneId,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.addShippingInCheckout,
        data: {
          'checkoutId': checkoutId,
          'shippingZoneId': shippingZoneId,
        },
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        return AddShippingResult.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to update shipping',
      );
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      ToastUtil.showToast('Failed to update shipping');
      return null;
    }
  }

  /// POST /api/payment/cod-payment
  /// Places a Cash on Delivery order for physical products.
  Future<bool> placeCodOrder(String checkoutId) async {
    try {
      final response = await _client.post(
        ApiConstants.codPayment,
        data: {'checkoutId': checkoutId},
        requiresAuth: true,
      );

      if (response.data['success'] == true) return true;

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to place order',
      );
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      ToastUtil.showToast('Failed to place order');
      return false;
    }
  }
}

// ── Response models ────────────────────────────────────────────────────────────

class AddShippingResult {
  final double shippingFee;
  final double subtotal;
  final double totalAmount;

  AddShippingResult({
    required this.shippingFee,
    required this.subtotal,
    required this.totalAmount,
  });

  factory AddShippingResult.fromJson(Map<String, dynamic> json) {
    return AddShippingResult(
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}
