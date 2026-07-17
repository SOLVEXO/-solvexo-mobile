import 'package:book_store_app/app/data/models/subscriptions/buyer_credit_wallet_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/buyer_store_benefits_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/buyer_store_plan_model.dart';
import 'package:book_store_app/app/data/models/subscriptions/buyer_subscription_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Buyer side of store memberships (subscriptions): browse a store's public
/// plans, subscribe, and self-manage subscriptions, benefits, and credits.
class BuyerMembershipsRepository {
  final BaseClient _client = BaseClient();

  /// Public catalog — a store's active plans (no auth required).
  Future<List<BuyerStorePlanModel>> getStorePlans(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.buyerStorePlans(storeId));
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .cast<Map<String, dynamic>>()
            .map(BuyerStorePlanModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getStorePlans error: $e');
      ToastUtil.showToast('Failed to load membership plans.');
      return [];
    }
  }

  /// Subscribes the buyer to [planId]. Returns the created subscription, or
  /// null on failure (backend message is toasted).
  Future<BuyerSubscriptionModel?> subscribe({
    required String planId,
    required String billingInterval, // 'monthly' | 'yearly'
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.buyerMembershipSubscribe,
        data: {'planId': planId, 'billingInterval': billingInterval},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast('Subscribed successfully');
        final data = response.data['data'] as Map<String, dynamic>;
        return BuyerSubscriptionModel.fromJson(data['subscription'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to subscribe');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ subscribe error: $e');
      ToastUtil.showToast('Failed to subscribe.');
      return null;
    }
  }

  /// The buyer's memberships across every store.
  Future<List<BuyerSubscriptionModel>> getMyMemberships({
    int page = 1,
    int limit = 50,
    String? status,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.buyerMyMemberships,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
        },
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return (data['subscriptions'] as List)
            .cast<Map<String, dynamic>>()
            .map(BuyerSubscriptionModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getMyMemberships error: $e');
      ToastUtil.showToast('Failed to load memberships.');
      return [];
    }
  }

  /// Full detail for a single membership — includes its invoice history.
  Future<BuyerSubscriptionModel?> getMembershipById(String id) async {
    try {
      final response = await _client.get(
        ApiConstants.buyerMyMembershipById(id),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return BuyerSubscriptionModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getMembershipById error: $e');
      ToastUtil.showToast('Failed to load membership details.');
      return null;
    }
  }

  Future<BuyerSubscriptionModel?> pauseMembership(String id) async {
    try {
      final response = await _client.patch(
        ApiConstants.buyerMembershipPause(id),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Membership paused');
        return BuyerSubscriptionModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to pause membership');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ pauseMembership error: $e');
      ToastUtil.showToast('Failed to pause membership.');
      return null;
    }
  }

  Future<BuyerSubscriptionModel?> resumeMembership(String id) async {
    try {
      final response = await _client.patch(
        ApiConstants.buyerMembershipResume(id),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Membership resumed');
        return BuyerSubscriptionModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to resume membership');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ resumeMembership error: $e');
      ToastUtil.showToast('Failed to resume membership.');
      return null;
    }
  }

  /// Cancels a membership — immediately, or at the end of the current period
  /// when [atPeriodEnd] is true.
  Future<BuyerSubscriptionModel?> cancelMembership(
    String id, {
    bool atPeriodEnd = false,
    String? reason,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.buyerMembershipCancel(id, atPeriodEnd: atPeriodEnd),
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Membership canceled');
        return BuyerSubscriptionModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to cancel membership');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ cancelMembership error: $e');
      ToastUtil.showToast('Failed to cancel membership.');
      return null;
    }
  }

  /// The buyer's active membership benefits at one store.
  /// `subscribed: false` when they have no active membership there.
  Future<BuyerStoreBenefitsModel> getStoreBenefits(String storeId) async {
    try {
      final response = await _client.get(
        ApiConstants.buyerMembershipBenefits(storeId),
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return BuyerStoreBenefitsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return BuyerStoreBenefitsModel.empty;
    } on DioException catch (e) {
      // Silent — fetched opportunistically on the storefront, where guests
      // (401) shouldn't see an error toast.
      DioExceptionHandler.handleDioException(e, showToast: false);
      return BuyerStoreBenefitsModel.empty;
    } catch (e) {
      debugPrint('❌ getStoreBenefits error: $e');
      return BuyerStoreBenefitsModel.empty;
    }
  }

  /// Every credit wallet the buyer holds, across all stores.
  Future<List<BuyerCreditWalletModel>> getCreditWallets() async {
    try {
      final response = await _client.get(
        ApiConstants.buyerMembershipCredits,
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .cast<Map<String, dynamic>>()
            .map(BuyerCreditWalletModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getCreditWallets error: $e');
      ToastUtil.showToast('Failed to load credits.');
      return [];
    }
  }
}
