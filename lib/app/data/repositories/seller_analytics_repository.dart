import 'dart:convert';

import 'package:book_store_app/app/data/models/analytics/analytics_overview_model.dart';
import 'package:book_store_app/app/data/models/analytics/customer_analytics_model.dart';
import 'package:book_store_app/app/data/models/analytics/inventory_insights_model.dart';
import 'package:book_store_app/app/data/models/analytics/payment_method_breakdown_model.dart';
import 'package:book_store_app/app/data/models/analytics/product_performance_model.dart';
import 'package:book_store_app/app/data/models/analytics/revenue_point_model.dart';
import 'package:book_store_app/app/data/models/analytics/top_product_analytics_model.dart';
import 'package:book_store_app/app/data/models/analytics/traffic_source_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// A 403 from an advanced-analytics route (docs 2.7 / #16). Real message:
/// 'Advanced analytics is not included in your current platform plan —
/// available starting with the "Pro" plan.'
class PlanLockedException implements Exception {
  const PlanLockedException(this.message);
  final String message;

  static const fallback = 'This is not included in your current plan.';

  static PlanLockedException? from(DioException e) {
    if (e.response?.statusCode != 403) return null;
    var data = e.response?.data;
    if (data is List<int>) {
      try {
        data = jsonDecode(utf8.decode(data));
      } catch (_) {}
    }
    return PlanLockedException(ApiError.msg(data is Map ? data['message'] : null) ?? fallback);
  }

  @override
  String toString() => message;
}

class SellerAnalyticsRepository {
  SellerAnalyticsRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  /// 403 -> [PlanLockedException] (no toast); anything else as before.
  void _handle(DioException e) {
    final lock = PlanLockedException.from(e);
    if (lock != null) throw lock;
    DioExceptionHandler.handleDioException(e);
  }

  Map<String, dynamic> _rangeParams(String storeId, String range, {String? from, String? to, bool compare = false}) {
    return {
      'storeId': storeId,
      'range': range,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (compare) 'compareToPreviousPeriod': true,
    };
  }

  /// Seller dashboard's "Today's Revenue" live card — today-so-far vs the
  /// same elapsed window yesterday. `revenueChangePercent` is null when
  /// yesterday had no revenue in that window (no meaningful "% change" from
  /// zero). Deliberately has no visitors/conversion-rate fields — the
  /// backend has no storefront visit-tracking to compute them from.
  Future<({double revenue, double? revenueChangePercent, int ordersCount, double avgOrderValue})> getTodaySummary(
    String storeId,
  ) async {
    const empty = (revenue: 0.0, revenueChangePercent: null, ordersCount: 0, avgOrderValue: 0.0);
    try {
      final response = await _client.get(
        ApiConstants.analyticsToday,
        queryParameters: {'storeId': storeId},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (
          revenue: (data['revenue'] as num?)?.toDouble() ?? 0.0,
          revenueChangePercent: (data['revenueChangePercent'] as num?)?.toDouble(),
          ordersCount: data['ordersCount'] as int? ?? 0,
          avgOrderValue: (data['avgOrderValue'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return empty;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return empty;
    } catch (e) {
      debugPrint('❌ getTodaySummary error: $e');
      return empty;
    }
  }

  Future<AnalyticsOverviewModel> getOverview(String storeId, String range, {String? from, String? to}) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsOverview,
        queryParameters: _rangeParams(storeId, range, from: from, to: to),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return AnalyticsOverviewModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return AnalyticsOverviewModel.empty;
    } on DioException catch (e) {
      _handle(e);
      return AnalyticsOverviewModel.empty;
    } catch (e) {
      debugPrint('❌ getOverview error: $e');
      ToastUtil.showToast('Failed to load analytics overview.');
      return AnalyticsOverviewModel.empty;
    }
  }

  Future<({String granularity, List<RevenuePointModel> series})> getRevenueOverTime(
    String storeId, String range, {String? from, String? to,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsRevenueOverTime,
        queryParameters: _rangeParams(storeId, range, from: from, to: to),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final series = (data['series'] as List).cast<Map<String, dynamic>>().map(RevenuePointModel.fromJson).toList();
        return (granularity: data['granularity'] as String? ?? 'day', series: series);
      }
      return (granularity: 'day', series: <RevenuePointModel>[]);
    } on DioException catch (e) {
      _handle(e);
      return (granularity: 'day', series: <RevenuePointModel>[]);
    } catch (e) {
      debugPrint('❌ getRevenueOverTime error: $e');
      return (granularity: 'day', series: <RevenuePointModel>[]);
    }
  }

  Future<({String granularity, List<OrderPointModel> series})> getOrdersOverTime(
    String storeId, String range, {String? from, String? to,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsOrdersOverTime,
        queryParameters: _rangeParams(storeId, range, from: from, to: to),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final series = (data['series'] as List).cast<Map<String, dynamic>>().map(OrderPointModel.fromJson).toList();
        return (granularity: data['granularity'] as String? ?? 'day', series: series);
      }
      return (granularity: 'day', series: <OrderPointModel>[]);
    } on DioException catch (e) {
      _handle(e);
      return (granularity: 'day', series: <OrderPointModel>[]);
    } catch (e) {
      debugPrint('❌ getOrdersOverTime error: $e');
      return (granularity: 'day', series: <OrderPointModel>[]);
    }
  }

  Future<List<TrafficSourceModel>> getTrafficSources(String storeId, String range, {String? from, String? to}) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsTrafficSources,
        queryParameters: _rangeParams(storeId, range, from: from, to: to),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (data['breakdown'] as List).cast<Map<String, dynamic>>().map(TrafficSourceModel.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      _handle(e);
      return [];
    } catch (e) {
      debugPrint('❌ getTrafficSources error: $e');
      return [];
    }
  }

  Future<List<TopProductAnalyticsModel>> getTopProducts(
    String storeId, String range, {String? from, String? to, int limit = 10, String sort = 'revenue'}
  ) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsTopProducts,
        queryParameters: {..._rangeParams(storeId, range, from: from, to: to), 'limit': limit, 'sort': sort},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return (response.data['data'] as List).cast<Map<String, dynamic>>().map(TopProductAnalyticsModel.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      _handle(e);
      return [];
    } catch (e) {
      debugPrint('❌ getTopProducts error: $e');
      return [];
    }
  }

  Future<CustomerAnalyticsModel> getCustomerAnalytics(String storeId, String range, {String? from, String? to}) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsCustomers,
        queryParameters: _rangeParams(storeId, range, from: from, to: to),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return CustomerAnalyticsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return CustomerAnalyticsModel.empty;
    } on DioException catch (e) {
      _handle(e);
      return CustomerAnalyticsModel.empty;
    } catch (e) {
      debugPrint('❌ getCustomerAnalytics error: $e');
      return CustomerAnalyticsModel.empty;
    }
  }

  Future<({List<ProductPerformanceModel> products, int total, int totalPages})> getProductPerformance(
    String storeId, String range, {String? from, String? to, int page = 1, int limit = 20}
  ) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsProductPerformance,
        queryParameters: {..._rangeParams(storeId, range, from: from, to: to), 'page': page, 'limit': limit},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final products = (data['products'] as List).cast<Map<String, dynamic>>().map(ProductPerformanceModel.fromJson).toList();
        return (products: products, total: pagination['total'] as int? ?? 0, totalPages: pagination['totalPages'] as int? ?? 1);
      }
      return (products: <ProductPerformanceModel>[], total: 0, totalPages: 1);
    } on DioException catch (e) {
      _handle(e);
      return (products: <ProductPerformanceModel>[], total: 0, totalPages: 1);
    } catch (e) {
      debugPrint('❌ getProductPerformance error: $e');
      return (products: <ProductPerformanceModel>[], total: 0, totalPages: 1);
    }
  }

  Future<InventoryInsightsModel> getInventoryInsights(String storeId) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsInventoryInsights,
        queryParameters: {'storeId': storeId},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return InventoryInsightsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return InventoryInsightsModel.empty;
    } on DioException catch (e) {
      _handle(e);
      return InventoryInsightsModel.empty;
    } catch (e) {
      debugPrint('❌ getInventoryInsights error: $e');
      return InventoryInsightsModel.empty;
    }
  }

  Future<List<PaymentMethodBreakdownModel>> getPaymentMethods(String storeId, String range, {String? from, String? to}) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsPaymentMethods,
        queryParameters: _rangeParams(storeId, range, from: from, to: to),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return (response.data['data'] as List).cast<Map<String, dynamic>>().map(PaymentMethodBreakdownModel.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      _handle(e);
      return [];
    } catch (e) {
      debugPrint('❌ getPaymentMethods error: $e');
      return [];
    }
  }

  Future<RevenueBreakdownModel> getRevenueBreakdown(String storeId, String range, {String? from, String? to}) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsRevenueBreakdown,
        queryParameters: _rangeParams(storeId, range, from: from, to: to),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return RevenueBreakdownModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return RevenueBreakdownModel.empty;
    } on DioException catch (e) {
      _handle(e);
      return RevenueBreakdownModel.empty;
    } catch (e) {
      debugPrint('❌ getRevenueBreakdown error: $e');
      return RevenueBreakdownModel.empty;
    }
  }

  /// CSV export — returns the raw CSV text, or null on failure.
  Future<String?> exportCsv(String storeId, String range, {String? from, String? to, required String section}) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsExport,
        queryParameters: {..._rangeParams(storeId, range, from: from, to: to), 'format': 'csv', 'section': section},
        requiresAuth: true,
      );
      return response.data.toString();
    } on DioException catch (e) {
      _handle(e);
      return null;
    } catch (e) {
      debugPrint('❌ exportCsv error: $e');
      ToastUtil.showToast('Failed to export CSV.');
      return null;
    }
  }

  /// PDF export — returns the raw PDF bytes, or null on failure.
  Future<List<int>?> exportPdf(String storeId, String range, {String? from, String? to}) async {
    try {
      final response = await _client.get(
        ApiConstants.analyticsExport,
        queryParameters: {..._rangeParams(storeId, range, from: from, to: to), 'format': 'pdf'},
        requiresAuth: true,
        responseType: ResponseType.bytes,
      );
      return response.data as List<int>;
    } on DioException catch (e) {
      _handle(e);
      return null;
    } catch (e) {
      debugPrint('❌ exportPdf error: $e');
      ToastUtil.showToast('Failed to export PDF.');
      return null;
    }
  }
}
