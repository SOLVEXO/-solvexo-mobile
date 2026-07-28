import 'package:book_store_app/app/data/models/platform_plans/platform_addon_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_entitlements_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_invoice_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_plan_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// The seller's OWN platform plan (paid to the marketplace) via the
/// DB-managed `/api/platform-plans` system — distinct from
/// `subscription_plans_repository.dart`, which is the seller selling plans
/// TO their own buyers.
class PlatformPlansRepository {
  final BaseClient _client = BaseClient();
  static const _uuid = Uuid();

  /// Billing mutations send an Idempotency-Key so an app retry/double-tap can
  /// never double-charge — the backend caches the first response for 24h.
  Map<String, dynamic> get _idempotencyHeader => {'Idempotency-Key': _uuid.v4()};

  Future<List<PlatformPlanModel>> getPublicPlans() async {
    try {
      final response = await _client.get(ApiConstants.platformPlansPublic, requiresAuth: false);
      if (response.data['success'] == true) {
        return (response.data['data'] as List? ?? [])
            .map((e) => PlatformPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getPublicPlans error: $e');
      return [];
    }
  }

  Future<PlatformSubscriptionModel?> getStorePlan(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.platformStorePlan(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return PlatformSubscriptionModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getStorePlan error: $e');
      return null;
    }
  }

  Future<PlatformEntitlementsModel?> getEntitlements(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.platformEntitlements(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return PlatformEntitlementsModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getEntitlements error: $e');
      return null;
    }
  }

  Future<PlatformSubscriptionModel?> changePlan(
    String storeId, {
    required String planId,
    required String billingInterval,
  }) async {
    try {
      final response = await _client.patch(
        ApiConstants.platformChangePlan(storeId),
        data: {'newPlatformPlanId': planId, 'newBillingInterval': billingInterval},
        requiresAuth: true,
        headers: _idempotencyHeader,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] as String? ?? 'Plan updated');
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        final sub = data['subscription'];
        return sub != null ? PlatformSubscriptionModel.fromJson(sub as Map<String, dynamic>) : null;
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to change plan.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ changePlan error: $e');
      ToastUtil.showToast('Failed to change plan.');
      return null;
    }
  }

  /// The store's platform-plan billing history, newest first.
  Future<({List<PlatformInvoiceModel> invoices, int total, int pages})> getInvoices(
    String storeId, {
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.platformInvoices(storeId),
        requiresAuth: true,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        return (
          invoices: (data['invoices'] as List? ?? [])
              .map((e) => PlatformInvoiceModel.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: data['total'] as int? ?? 0,
          pages: data['pages'] as int? ?? 1,
        );
      }
      return (invoices: <PlatformInvoiceModel>[], total: 0, pages: 0);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (invoices: <PlatformInvoiceModel>[], total: 0, pages: 0);
    } catch (e) {
      debugPrint('❌ getInvoices error: $e');
      return (invoices: <PlatformInvoiceModel>[], total: 0, pages: 0);
    }
  }

  Future<List<PlatformAddonModel>> getAddons(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.platformAddons(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return (response.data['data'] as List? ?? [])
            .map((e) => PlatformAddonModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return [];
    } catch (e) {
      debugPrint('❌ getAddons error: $e');
      return [];
    }
  }

  Future<bool> purchaseAddon(String storeId, {required String addonType, int quantity = 1}) async {
    try {
      final response = await _client.post(
        ApiConstants.platformAddons(storeId),
        data: {'addonType': addonType, 'quantity': quantity},
        requiresAuth: true,
        headers: _idempotencyHeader,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] as String? ?? 'Add-on activated');
        return true;
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to purchase add-on.');
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ purchaseAddon error: $e');
      return false;
    }
  }

  Future<bool> cancelAddon(String storeId, String addonId) async {
    try {
      final response = await _client.delete(ApiConstants.platformCancelAddon(storeId, addonId));
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] as String? ?? 'Add-on canceled');
        return true;
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to cancel add-on.');
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ cancelAddon error: $e');
      return false;
    }
  }

  /// Dry-run pricing preview for [selectPlan] — no charge/DB write. Lets the
  /// UI show "amount due today" / credit math before the seller commits via
  /// the real `changePlan` call.
  Future<PlatformPlanPreviewResult?> previewChangePlan(
    String storeId, {
    required String newPlatformPlanId,
    required String newBillingInterval,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.platformPreviewChangePlan(storeId),
        data: {'newPlatformPlanId': newPlatformPlanId, 'newBillingInterval': newBillingInterval},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        return PlatformPlanPreviewResult.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to preview plan change.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ previewChangePlan error: $e');
      ToastUtil.showToast('Failed to preview plan change.');
      return null;
    }
  }

  /// Schedules a downgrade-to-free at the end of the current billing period
  /// — access is unaffected until then. [reason] is optional, max 500 chars.
  Future<PlatformSubscriptionModel?> cancelSubscription(String storeId, {String? reason}) async {
    try {
      final response = await _client.post(
        ApiConstants.platformCancelPlan(storeId),
        data: {if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim()},
        requiresAuth: true,
        headers: _idempotencyHeader,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] as String? ?? 'Cancellation scheduled.');
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        final sub = data['subscription'];
        return sub != null ? PlatformSubscriptionModel.fromJson(sub as Map<String, dynamic>) : null;
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to cancel subscription.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ cancelSubscription error: $e');
      ToastUtil.showToast('Failed to cancel subscription.');
      return null;
    }
  }

  /// Undoes a pending cancellation scheduled by [cancelSubscription].
  Future<PlatformSubscriptionModel?> reactivateSubscription(String storeId) async {
    try {
      final response = await _client.post(
        ApiConstants.platformReactivatePlan(storeId),
        requiresAuth: true,
        headers: _idempotencyHeader,
      );
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] as String? ?? 'Subscription reactivated.');
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        final sub = data['subscription'];
        return sub != null ? PlatformSubscriptionModel.fromJson(sub as Map<String, dynamic>) : null;
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to reactivate subscription.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ reactivateSubscription error: $e');
      ToastUtil.showToast('Failed to reactivate subscription.');
      return null;
    }
  }

  /// Returns a Stripe-hosted billing-portal URL for this store (or, if the
  /// manual-payment provider is active, just [returnUrl] echoed back).
  Future<String?> openBillingPortal(String storeId, {required String returnUrl}) async {
    try {
      final response = await _client.post(
        ApiConstants.platformBillingPortal(storeId),
        data: {'returnUrl': returnUrl},
        requiresAuth: true,
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        return data['url'] as String?;
      }
      ToastUtil.showToast(response.data['message'] as String? ?? 'Failed to open billing portal.');
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ openBillingPortal error: $e');
      ToastUtil.showToast('Failed to open billing portal.');
      return null;
    }
  }
}

/// `POST .../preview-change-plan` dry-run result — pricing math for a
/// prospective plan/interval switch, shown in [PlanChangePreviewSheet] before
/// the seller commits via the real `changePlan` call.
class PlatformPlanPreviewResult {
  final String direction; // 'upgrade' | 'downgrade' | 'billing_interval_change'
  final String currentPlanName;
  final double currentAmountUSD;
  final String newPlanName;
  final double newAmountUSD;
  final String newBillingInterval;
  final int remainingDaysInCurrentPeriod;
  final double unusedCreditFromCurrentPlanUSD;
  final double existingCreditBalanceUSD;
  final double totalCreditAppliedUSD;
  final double amountDueTodayUSD;
  final double creditAppliedToBalanceUSD;
  final bool effectiveImmediately;

  const PlatformPlanPreviewResult({
    required this.direction,
    required this.currentPlanName,
    required this.currentAmountUSD,
    required this.newPlanName,
    required this.newAmountUSD,
    required this.newBillingInterval,
    required this.remainingDaysInCurrentPeriod,
    required this.unusedCreditFromCurrentPlanUSD,
    required this.existingCreditBalanceUSD,
    required this.totalCreditAppliedUSD,
    required this.amountDueTodayUSD,
    required this.creditAppliedToBalanceUSD,
    required this.effectiveImmediately,
  });

  factory PlatformPlanPreviewResult.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v as num?)?.toDouble() ?? 0;
    return PlatformPlanPreviewResult(
      direction: json['direction'] as String? ?? 'upgrade',
      currentPlanName: json['currentPlanName'] as String? ?? '',
      currentAmountUSD: d(json['currentAmountUSD']),
      newPlanName: json['newPlanName'] as String? ?? '',
      newAmountUSD: d(json['newAmountUSD']),
      newBillingInterval: json['newBillingInterval'] as String? ?? 'monthly',
      remainingDaysInCurrentPeriod: (json['remainingDaysInCurrentPeriod'] as num?)?.toInt() ?? 0,
      unusedCreditFromCurrentPlanUSD: d(json['unusedCreditFromCurrentPlanUSD']),
      existingCreditBalanceUSD: d(json['existingCreditBalanceUSD']),
      totalCreditAppliedUSD: d(json['totalCreditAppliedUSD']),
      amountDueTodayUSD: d(json['amountDueTodayUSD']),
      creditAppliedToBalanceUSD: d(json['creditAppliedToBalanceUSD']),
      effectiveImmediately: json['effectiveImmediately'] as bool? ?? true,
    );
  }
}
