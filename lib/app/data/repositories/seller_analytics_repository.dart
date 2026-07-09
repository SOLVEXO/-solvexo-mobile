import 'package:book_store_app/app/data/models/analytics/analytics_overview_model.dart';
import 'package:book_store_app/app/data/models/analytics/customer_analytics_model.dart';
import 'package:book_store_app/app/data/models/analytics/inventory_insights_model.dart';
import 'package:book_store_app/app/data/models/analytics/payment_method_breakdown_model.dart';
import 'package:book_store_app/app/data/models/analytics/product_performance_model.dart';
import 'package:book_store_app/app/data/models/analytics/revenue_point_model.dart';
import 'package:book_store_app/app/data/models/analytics/top_product_analytics_model.dart';
import 'package:book_store_app/app/data/models/analytics/traffic_source_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SellerAnalyticsRepository {
  final BaseClient _client = BaseClient();

  Map<String, dynamic> _rangeParams(String storeId, String range, {String? from, String? to, bool compare = false}) {
    return {
      'storeId': storeId,
      'range': range,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (compare) 'compareToPreviousPeriod': true,
    };
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
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
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ exportPdf error: $e');
      ToastUtil.showToast('Failed to export PDF.');
      return null;
    }
  }
}
