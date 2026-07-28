import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SellerOrdersRepository {
  final BaseClient _client = BaseClient();

  // ─── GET /api/orders/seller-orders/:storeId ───────────────────────────────

  Future<
      ({
        List<Map<String, dynamic>> orders,
        Map<String, dynamic> stats,
        int totalOrders,
        bool hasMore,
      })> fetchSellerOrders({
    required String storeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.sellerOrders(storeId),
        queryParameters: {'page': page, 'limit': limit},
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final orders =
            (data['orders'] as List).cast<Map<String, dynamic>>();
        final stats =
            (data['stats'] as Map<String, dynamic>?) ?? {};
        final totalOrders = pagination['totalOrders'] as int? ?? 0;
        final totalPages = pagination['totalPages'] as int? ?? 1;

        return (
          orders: orders,
          stats: stats,
          totalOrders: totalOrders,
          hasMore: page < totalPages,
        );
      }

      return (
        orders: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        totalOrders: 0,
        hasMore: false,
      );
    } on DioException catch (e) {
      debugPrint('❌ fetchSellerOrders DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return (
        orders: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        totalOrders: 0,
        hasMore: false,
      );
    } catch (e) {
      debugPrint('❌ fetchSellerOrders error: $e');
      ToastUtil.showToast('Failed to load orders. Please try again.');
      return (
        orders: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        totalOrders: 0,
        hasMore: false,
      );
    }
  }

  // ─── PUT /api/orders/update-status ───────────────────────────────────────

  Future<bool> updateOrderStatus({
    required String orderId,
    required String storeId,
    required String status,
    Map<String, String>? tracking,
  }) async {
    try {
      final body = <String, dynamic>{
        'orderId': orderId,
        'storeId': storeId,
        'status': status,
        if (tracking != null && tracking.isNotEmpty) 'tracking': tracking,
      };
      final response = await _client.put(
        ApiConstants.updateOrderStatus,
        data: body,
        requiresAuth: true,
      );

      if (response.data['success'] == true) return true;

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to update status',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ updateOrderStatus DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ updateOrderStatus error: $e');
      ToastUtil.showToast('Failed to update order status');
      return false;
    }
  }

  // ─── POST /api/orders/mark-paid/:orderId ──────────────────────────────────

  Future<bool> markOrderPaid(String orderId) async {
    try {
      final response = await _client.put(
        ApiConstants.markOrderPaid(orderId),
        requiresAuth: true,
      );

      if (response.data['success'] == true) return true;

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to mark order as paid',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ markOrderPaid DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ markOrderPaid error: $e');
      ToastUtil.showToast('Failed to mark order as paid');
      return false;
    }
  }

  // ─── GET /api/orders/returns ───────────────────────────────────────────────

  Future<
      ({
        List<Map<String, dynamic>> returns,
        Map<String, dynamic> stats,
        bool hasMore,
      })> fetchSellerReturns({
    required String storeId,
    String? status,
    int page = 1,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.sellerReturns,
        queryParameters: {
          'storeId': storeId,
          'page': page,
          if (status != null && status != 'all') 'status': status,
        },
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        final returns =
            (data['returns'] as List? ?? []).cast<Map<String, dynamic>>();
        final stats = (data['stats'] as Map<String, dynamic>?) ?? {};
        final totalPages = pagination['totalPages'] as int? ?? 1;

        return (returns: returns, stats: stats, hasMore: page < totalPages);
      }

      return (
        returns: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        hasMore: false,
      );
    } on DioException catch (e) {
      debugPrint('❌ fetchSellerReturns DioException: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');
      DioExceptionHandler.handleDioException(e);
      return (
        returns: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        hasMore: false,
      );
    } catch (e) {
      debugPrint('❌ fetchSellerReturns error: $e');
      ToastUtil.showToast('Failed to load returns. Please try again.');
      return (
        returns: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        hasMore: false,
      );
    }
  }

  // ─── PUT /api/orders/return-action/:orderId ────────────────────────────────

  Future<bool> returnAction({
    required String orderId,
    required String storeId,
    required List<String> itemIds,
    required String action, // 'approve' | 'reject'
    String? rejectReason,
  }) async {
    try {
      final response = await _client.put(
        ApiConstants.returnAction(orderId),
        data: {
          'storeId': storeId,
          'itemIds': itemIds,
          'action': action,
          if (rejectReason != null && rejectReason.isNotEmpty)
            'rejectReason': rejectReason,
        },
        requiresAuth: true,
      );

      if (response.data['success'] == true) return true;

      ToastUtil.showToast(
        response.data['message'] as String? ?? 'Failed to process return',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ returnAction DioException: ${e.response?.statusCode}');
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ returnAction error: $e');
      ToastUtil.showToast('Failed to process return');
      return false;
    }
  }
}
