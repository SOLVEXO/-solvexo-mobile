import 'package:book_store_app/app/modules/checkout/models/order_request_model.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OrderRepository {
  final BaseClient _baseClient = BaseClient();

  /// GET /api/orders/my-orders
  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 20}) async {
    try {
      debugPrint('🔄 Fetching my orders (page $page)...');

      final response = await _baseClient.get(
        ApiConstants.myOrders,
        queryParameters: {'page': page, 'limit': limit},
        requiresAuth: true,
      );

      debugPrint('✅ Get My Orders status: ${response.statusCode}');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final orderList = (data['orders'] as List? ?? [])
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Parsed ${orderList.length} orders');
        return orderList;
      }

      debugPrint('⚠️ Response not successful: ${response.data}');
      return [];
    } catch (e) {
      debugPrint('❌ Get My Orders error: $e');
      rethrow;
    }
  }

  /// Place new order
  Future<OrderModel?> placeOrder(OrderRequestModel orderData) async {
    try {
      // final token = await AppPreferences.getAccessTokenAsync();

      debugPrint('🔄 Placing order...');
      debugPrint('Order data: ${orderData.toJson()}');

      final response = await _baseClient.post(
        ApiConstants.orders,

        data: orderData.toJson(),
      );

      debugPrint('✅ Place Order Response: ${response.data}');

      // ✅ NestJS returns: { success: true, message: "...", data: {...} }
      if (response.statusCode == 201 && response.data['success'] == true) {
        final order = OrderModel.fromJson(response.data['data']);
        debugPrint('✅ Order created: ${order.orderId}');
        return order;
      }

      return null;
    } catch (e) {
      if (e is DioException) {
        debugPrint("❌ BACKEND ERROR BODY:");
        debugPrint("${e.response?.data}");
      }
      rethrow;
    }
  }

  /// Get single order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      // final token = await AppPreferences.getAccessTokenAsync();

      debugPrint('🔄 Fetching order: $orderId');

      final response = await _baseClient.get('${ApiConstants.orders}/$orderId');

      debugPrint('✅ Get Order Response: ${response.data}');

      if (response.data['success'] == true) {
        return OrderModel.fromJson(response.data['data']);
      }

      return null;
    } catch (e) {
      debugPrint('❌ Get Order error: $e');
      rethrow;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      // final token = await AppPreferences.getAccessTokenAsync();

      debugPrint('🔄 Cancelling order: $orderId');

      final response = await _baseClient.put(
        '${ApiConstants.orders}/$orderId/cancel',
      );

      debugPrint('✅ Cancel Order Response: ${response.data}');

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ Cancel Order error: $e');
      rethrow;
    }
  }

  /// Update order to paid
  Future<bool> updateOrderToPaid({
    required String orderId,
    required String paymentId,
    required String paymentStatus,
    String? emailAddress,
  }) async {
    try {
      // final token = await AppPreferences.getAccessTokenAsync();

      debugPrint('🔄 Updating order to paid: $orderId');

      final response = await _baseClient.put(
        '${ApiConstants.orders}/$orderId/pay',

        data: {
          'id': paymentId,
          'status': paymentStatus,
          'update_time': DateTime.now().toIso8601String(),
          'email_address': emailAddress,
        },
      );

      debugPrint('✅ Update to Paid Response: ${response.data}');

      return response.data['success'] == true;
    } catch (e) {
      debugPrint('❌ Update to Paid error: $e');
      rethrow;
    }
  }
}
