import 'package:book_store_app/app/data/models/subscriptions/subscriber_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/subscription_dashboard_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/subscription_plan_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SubscriptionPlansRepository {
  final BaseClient _client = BaseClient();

  // ─── Plans ────────────────────────────────────────────────────────────────

  Future<List<SubscriptionPlanModel>> listPlans(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.subscriptionPlans(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return (response.data['data'] as List).cast<Map<String, dynamic>>().map(SubscriptionPlanModel.fromJson).toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ listPlans error: $e');
      ToastUtil.showToast('Failed to load subscription plans.');
      return [];
    }
  }

  Future<SubscriptionPlanModel?> createPlan(
    String storeId, {
    required String name,
    String? description,
    required double monthlyPriceUSD,
    double? yearlyPriceUSD,
    String? displayCurrency,
    List<String>? features,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.subscriptionPlans(storeId),
        data: {
          'name': name,
          if (description != null) 'description': description,
          'monthlyPriceUSD': monthlyPriceUSD,
          if (yearlyPriceUSD != null) 'yearlyPriceUSD': yearlyPriceUSD,
          if (displayCurrency != null) 'displayCurrency': displayCurrency,
          if (features != null) 'features': features,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast('Plan created');
        return SubscriptionPlanModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ createPlan error: $e');
      ToastUtil.showToast('Failed to create plan.');
      return null;
    }
  }

  Future<SubscriptionPlanModel?> updatePlan(
    String storeId,
    String planId, {
    String? name,
    String? description,
    double? monthlyPriceUSD,
    double? yearlyPriceUSD,
    String? displayCurrency,
    List<String>? features,
    String? status,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.subscriptionPlanById(storeId, planId),
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (monthlyPriceUSD != null) 'monthlyPriceUSD': monthlyPriceUSD,
          if (yearlyPriceUSD != null) 'yearlyPriceUSD': yearlyPriceUSD,
          if (displayCurrency != null) 'displayCurrency': displayCurrency,
          if (features != null) 'features': features,
          if (status != null) 'status': status,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast('Plan updated');
        return SubscriptionPlanModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ updatePlan error: $e');
      ToastUtil.showToast('Failed to update plan.');
      return null;
    }
  }

  Future<bool> archivePlan(String storeId, String planId, {bool force = false}) async {
    try {
      final response = await _client.delete(
        '${ApiConstants.subscriptionPlanById(storeId, planId)}?force=$force',
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Plan archived');
        return true;
      }
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ archivePlan error: $e');
      ToastUtil.showToast('Failed to archive plan.');
      return false;
    }
  }

  // ─── Dashboard ────────────────────────────────────────────────────────────

  Future<SubscriptionDashboardModel> getDashboard(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.subscriptionsDashboard(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return SubscriptionDashboardModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return SubscriptionDashboardModel.empty;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return SubscriptionDashboardModel.empty;
    } catch (e) {
      debugPrint('❌ getDashboard error: $e');
      ToastUtil.showToast('Failed to load subscriptions dashboard.');
      return SubscriptionDashboardModel.empty;
    }
  }

  // ─── Subscribers ──────────────────────────────────────────────────────────

  Future<({List<SubscriberModel> subscribers, int total, int pages})> listSubscriptions(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? status,
    String? planId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.subscriptionsList(storeId),
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (planId != null) 'planId': planId,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final subs = (data['subscriptions'] as List).cast<Map<String, dynamic>>().map(SubscriberModel.fromJson).toList();
        return (subscribers: subs, total: pagination['total'] as int? ?? 0, pages: pagination['pages'] as int? ?? 1);
      }
      return (subscribers: <SubscriberModel>[], total: 0, pages: 1);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (subscribers: <SubscriberModel>[], total: 0, pages: 1);
    } catch (e) {
      debugPrint('❌ listSubscriptions error: $e');
      ToastUtil.showToast('Failed to load subscribers.');
      return (subscribers: <SubscriberModel>[], total: 0, pages: 1);
    }
  }

  Future<SubscriberModel?> getSubscriptionById(String storeId, String id) async {
    try {
      final response = await _client.get(ApiConstants.subscriptionById(storeId, id), requiresAuth: true);
      if (response.data['success'] == true) {
        return SubscriberModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getSubscriptionById error: $e');
      ToastUtil.showToast('Failed to load subscriber details.');
      return null;
    }
  }

  Future<bool> pauseSubscription(String storeId, String id) => _patchStatus(ApiConstants.subscriptionPause(storeId, id));
  Future<bool> resumeSubscription(String storeId, String id) => _patchStatus(ApiConstants.subscriptionResume(storeId, id));
  Future<bool> cancelSubscription(String storeId, String id, {bool atPeriodEnd = false}) =>
      _patchStatus(ApiConstants.subscriptionCancel(storeId, id, atPeriodEnd: atPeriodEnd));

  Future<bool> _patchStatus(String url) async {
    try {
      final response = await _client.patch(url, requiresAuth: true);
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Updated');
        return true;
      }
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ subscription status update error: $e');
      ToastUtil.showToast('Failed to update subscription.');
      return false;
    }
  }
}
