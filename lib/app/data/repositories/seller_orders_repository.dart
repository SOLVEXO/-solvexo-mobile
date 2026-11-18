import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart' show FreeClaim;
import 'package:book_store_app/app/modules/seller_returns/models/seller_return_item.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SellerOrdersRepository {
  SellerOrdersRepository({BaseClient? client}) : _client = client ?? BaseClient();

  final BaseClient _client;

  // ─── GET /api/orders/seller-free-claims/:storeId ──────────────────────────
  // Verified: {success, data:{claims:[], total, page, totalPages}}. Throws.
  Future<({List<FreeClaim> claims, int total})> getFreeClaims(String storeId, {int page = 1}) async {
    final res = await _client.get(
      ApiConstants.sellerFreeClaims(storeId),
      queryParameters: {'page': page},
      requiresAuth: true,
    );
    final data = Map<String, dynamic>.from((res.data as Map)['data'] as Map);
    final list = data['claims'] is List ? data['claims'] as List : const [];
    return (
      claims: list.whereType<Map>().map((m) => FreeClaim.fromJson(Map<String, dynamic>.from(m))).toList(),
      total: (data['total'] as num?)?.toInt() ?? list.length,
    );
  }

  // ─── GET /api/orders/seller-orders/:storeId ───────────────────────────────

  Future<
      ({
        List<Map<String, dynamic>> orders,
        Map<String, dynamic> stats,
        int totalOrders,
        bool hasMore,
        Map<String, int> counts,
        bool failed,
      })> fetchSellerOrders({
    required String storeId,
    int page = 1,
    int limit = 20,
    // needs_action | shipped | delivered | completed | cancelled | all
    // (verified; anything else -> 400 "Invalid tab"). With a tab the API
    // also returns data.counts for every tab (+ toShip, overdue).
    String? tab,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.sellerOrders(storeId),
        queryParameters: {'page': page, 'limit': limit, if (tab != null) 'tab': tab},
        requiresAuth: true,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final rawCounts = data['counts'] is Map ? data['counts'] as Map : const {};
        final counts = <String, int>{
          for (final e in rawCounts.entries)
            if (e.value is num) '${e.key}': (e.value as num).toInt(),
        };
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
          counts: counts,
          failed: false,
        );
      }

      return (
        orders: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        totalOrders: 0,
        hasMore: false,
        counts: <String, int>{},
        failed: true,
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
        counts: <String, int>{},
        failed: true,
      );
    } catch (e) {
      debugPrint('❌ fetchSellerOrders error: $e');
      ToastUtil.showToast('Failed to load orders. Please try again.');
      return (
        orders: <Map<String, dynamic>>[],
        stats: <String, dynamic>{},
        totalOrders: 0,
        hasMore: false,
        counts: <String, int>{},
        failed: true,
      );
    }
  }

  // ─── PUT /api/orders/update-status ───────────────────────────────────────

  Future<bool> updateOrderStatus({
    required String orderId,
    required String storeId,
    required String status,
    Map<String, String>? tracking,
    void Function()? onForbidden,
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
        ApiError.msg(response.data['message']) ?? 'Failed to update status',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ updateOrderStatus DioException: ${e.response?.statusCode}');
      if (e.response?.statusCode == 403) {
        // Edudeen-fulfilled sub-order: shipping status/tracking belong to Edudeen.
        onForbidden?.call();
        ToastUtil.showToast(
          ApiError.fromDio(e) ?? 'Edudeen manages this order\'s shipping.',
        );
        return false;
      }
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ updateOrderStatus error: $e');
      ToastUtil.showToast('Failed to update order status');
      return false;
    }
  }

  // ─── POST /api/orders/mark-paid/:orderId ──────────────────────────────────

  /// PUT /api/orders/mark-paid/:orderId {storeId}: confirms THIS store's
  /// COD package only (multi-seller orders are paid per package).
  Future<bool> markOrderPaid(
    String orderId, {
    required String storeId,
    void Function()? onForbidden,
  }) async {
    try {
      final response = await _client.put(
        ApiConstants.markOrderPaid(orderId),
        data: {'storeId': storeId},
        requiresAuth: true,
      );

      if (response.data['success'] == true) return true;

      ToastUtil.showToast(
        ApiError.msg(response.data['message']) ?? 'Failed to mark order as paid',
      );
      return false;
    } on DioException catch (e) {
      debugPrint('❌ markOrderPaid DioException: ${e.response?.statusCode}');
      if (e.response?.statusCode == 403) {
        // Only Edudeen can mark an Edudeen-fulfilled (platform COD) order paid.
        onForbidden?.call();
        ToastUtil.showToast(
          ApiError.fromDio(e) ?? 'Edudeen manages payment for this order.',
        );
        return false;
      }
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

  // ─── GET /api/orders/seller-returns-all/:storeId ───────────────────────────

  /// Throws on failure so the screen can show error + Retry.
  Future<({List<SellerReturnItem> items, SellerReturnStats stats, int totalPages})>
      getReturnsAll(String storeId, {int page = 1, int limit = 20}) async {
    final res = await _client.get(
      ApiConstants.sellerReturnsAll(storeId),
      queryParameters: {'page': page, 'limit': limit},
      requiresAuth: true,
    );
    final data = Map<String, dynamic>.from((res.data as Map)['data'] as Map);
    final rows = data['items'] is List ? data['items'] as List : const [];
    final pagination = data['pagination'] is Map ? data['pagination'] as Map : const {};
    return (
      items: rows
          .whereType<Map>()
          .map((m) => SellerReturnItem.fromJson(Map<String, dynamic>.from(m)))
          .toList(),
      stats: data['stats'] is Map
          ? SellerReturnStats.fromJson(Map<String, dynamic>.from(data['stats'] as Map))
          : SellerReturnStats.empty,
      totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  // ─── GET /api/orders/seller-returns-all/:storeId/:source/:requestId ─────────
  /// One row in full: item types, download counts, reject reason and the
  /// server's follow-up `actions`. Throws on failure.
  Future<SellerReturnDetail> getReturnDetail(String storeId, String source, String requestId) async {
    final res = await _client.get(ApiConstants.sellerReturnDetail(storeId, source, requestId), requiresAuth: true);
    return SellerReturnDetail.fromJson(Map<String, dynamic>.from((res.data as Map)['data'] as Map));
  }

  // ─── PATCH /api/orders/return-follow-up/:orderId ───────────────────────────
  // Backend 5adba44 (orders.service.ts ~1961): body {storeId, itemId, step,
  // note?}; only an approved return; item_received is physical only.
  Future<bool> returnFollowUp({
    required String orderId,
    required String storeId,
    required String itemId,
    required String step,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.returnFollowUp(orderId),
        data: {'storeId': storeId, 'itemId': itemId, 'step': step},
        requiresAuth: true,
      );
      if (response.data is Map && response.data['success'] == false) {
        ToastUtil.showToast(ApiError.msg(response.data['message']) ?? 'Could not update the return');
        return false;
      }
      return true;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (_) {
      ToastUtil.showToast('Could not update the return');
      return false;
    }
  }

  // ─── PUT /api/orders/return-action/:orderId ────────────────────────────────
  // Verified: {storeId, itemIds, action: approve|reject, rejectReason}; a
  // reject reason under 10 chars -> 400 "Please explain the rejection in at
  // least 10 characters (the buyer will see it)".

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
        ApiError.msg(response.data['message']) ?? 'Failed to process return',
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
