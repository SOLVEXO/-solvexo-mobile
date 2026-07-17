import 'package:book_store_app/app/modules/checkout/models/create_checkout_response.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';

class CheckoutRepository {
  final BaseClient _client = BaseClient();

  /// POST /api/checkout/create-checkout
  /// The server reads the cart from the auth token. [items] narrows the
  /// checkout to specific cart lines (`{productId, variantId}` pairs) —
  /// without it the backend checks out the ENTIRE cart, ignoring the
  /// selection checkboxes in the cart UI.
  Future<CreateCheckoutResponse?> createCheckout({
    List<Map<String, String>>? items,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.createCheckout,
        data: {
          if (items != null && items.isNotEmpty) 'items': items,
        },
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

  /// POST /api/checkout/apply-coupon
  /// Validates a seller coupon against this checkout and, if valid,
  /// discounts only the items belonging to that coupon's store. [message]
  /// carries the backend's validation error (e.g. "invalid code", "minimum
  /// order not met") so the caller can show it directly.
  Future<({bool success, CouponApplyResult? result, String? message})> applyCoupon({
    required String checkoutId,
    required String code,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.applyCoupon,
        data: {'checkoutId': checkoutId, 'code': code},
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        return (
          success: true,
          result: CouponApplyResult.fromJson(response.data['data'] as Map<String, dynamic>),
          message: null,
        );
      }
      return (success: false, result: null, message: response.data['message'] as String?);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      return (success: false, result: null, message: message ?? 'Failed to apply coupon');
    } catch (e) {
      return (success: false, result: null, message: 'Failed to apply coupon');
    }
  }

  /// POST /api/checkout/remove-coupon
  Future<AddShippingResult?> removeCoupon(String checkoutId) async {
    try {
      final response = await _client.post(
        ApiConstants.removeCoupon,
        data: {'checkoutId': checkoutId},
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        return AddShippingResult.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to remove coupon');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      ToastUtil.showToast('Failed to remove coupon');
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

  /// POST /api/payment/initiate-payment
  /// Creates (or reuses) a Stripe PaymentIntent for this checkout. [message]
  /// carries the backend's error text on failure (e.g. "not configured yet")
  /// so the caller can show it directly instead of a generic toast.
  Future<({bool success, PaymentIntentResult? intent, String? message})> initiatePayment(
    String checkoutId,
  ) async {
    try {
      final response = await _client.post(
        ApiConstants.initiatePayment,
        data: {'checkoutId': checkoutId},
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        return (
          success: true,
          intent: PaymentIntentResult.fromJson(response.data['data'] as Map<String, dynamic>),
          message: null,
        );
      }

      return (success: false, intent: null, message: response.data['message'] as String?);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] as String? : null;
      return (success: false, intent: null, message: message ?? 'Failed to start payment');
    } catch (e) {
      return (success: false, intent: null, message: 'Failed to start payment');
    }
  }

  /// GET /api/payment/status — polled after `presentPaymentSheet()` succeeds
  /// client-side, since webhook delivery timing can't be relied on from a
  /// mobile client. Returns 'pending' on any error so the caller can just
  /// keep polling rather than treat a transient network hiccup as failure.
  Future<PaymentStatusResult> getPaymentStatus(String checkoutId) async {
    try {
      final response = await _client.get(
        ApiConstants.paymentStatus,
        queryParameters: {'checkoutId': checkoutId},
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaymentStatusResult(
          status: data['status'] as String? ?? 'pending',
          orderIds: (data['orderIds'] as List?)?.cast<String>() ?? const [],
        );
      }
      return const PaymentStatusResult(status: 'pending', orderIds: []);
    } catch (e) {
      return const PaymentStatusResult(status: 'pending', orderIds: []);
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

class CouponApplyResult {
  final String couponCode;
  final double couponDiscountUSD;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;

  CouponApplyResult({
    required this.couponCode,
    required this.couponDiscountUSD,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
  });

  factory CouponApplyResult.fromJson(Map<String, dynamic> json) {
    return CouponApplyResult(
      couponCode: json['couponCode'] as String? ?? '',
      couponDiscountUSD: (json['couponDiscountUSD'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    );
  }
}

/// A Stripe PaymentIntent's client secret, ready to hand to
/// `Stripe.instance.initPaymentSheet`.
class PaymentIntentResult {
  final String clientSecret;
  final String paymentIntentId;
  final double amount;
  final String currency;

  PaymentIntentResult({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
  });

  factory PaymentIntentResult.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResult(
      clientSecret: json['clientSecret'] as String? ?? '',
      paymentIntentId: json['paymentIntentId'] as String? ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

/// 'pending' | 'completed' | 'failed'
class PaymentStatusResult {
  final String status;
  final List<String> orderIds;

  const PaymentStatusResult({required this.status, required this.orderIds});

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
