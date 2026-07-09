import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/data/models/platform_plans/platform_tier_model.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_exception_handler.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// The seller's OWN platform plan (paid to the marketplace) — distinct from
/// `subscription_plans_repository.dart`, which is the seller selling plans
/// TO their own buyers.
class PlatformPlansRepository {
  final BaseClient _client = BaseClient();

  Future<({List<PlatformTierModel> tiers, double posAddonMonthlyPriceUSD})> getTiers() async {
    try {
      final response = await _client.get(ApiConstants.platformTiers, requiresAuth: true);
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final tiers = (data['tiers'] as List).cast<Map<String, dynamic>>().map(PlatformTierModel.fromJson).toList();
        return (tiers: tiers, posAddonMonthlyPriceUSD: (data['posAddonMonthlyPriceUSD'] as num?)?.toDouble() ?? 29);
      }
      return (tiers: <PlatformTierModel>[], posAddonMonthlyPriceUSD: 29.0);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return (tiers: <PlatformTierModel>[], posAddonMonthlyPriceUSD: 29.0);
    } catch (e) {
      debugPrint('❌ getTiers error: $e');
      return (tiers: <PlatformTierModel>[], posAddonMonthlyPriceUSD: 29.0);
    }
  }

  Future<PlatformSubscriptionModel?> getMyPlan(String storeId) async {
    try {
      final response = await _client.get(ApiConstants.platformMyPlan(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        return PlatformSubscriptionModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ getMyPlan error: $e');
      return null;
    }
  }

  Future<PlatformSubscriptionModel?> subscribe(String storeId, {required String tier, required String billingInterval}) =>
      _postTier(ApiConstants.platformSubscribe(storeId), tier, billingInterval);

  Future<PlatformSubscriptionModel?> changeTier(String storeId, {required String tier, required String billingInterval}) =>
      _patchTier(ApiConstants.platformChangeTier(storeId), tier, billingInterval);

  Future<PlatformSubscriptionModel?> _postTier(String url, String tier, String billingInterval) async {
    try {
      final response = await _client.post(url, data: {'tier': tier, 'billingInterval': billingInterval}, requiresAuth: true);
      return _handleTierResponse(response);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ subscribe error: $e');
      ToastUtil.showToast('Failed to update your plan.');
      return null;
    }
  }

  Future<PlatformSubscriptionModel?> _patchTier(String url, String tier, String billingInterval) async {
    try {
      final response = await _client.patch(url, data: {'tier': tier, 'billingInterval': billingInterval}, requiresAuth: true);
      return _handleTierResponse(response);
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return null;
    } catch (e) {
      debugPrint('❌ changeTier error: $e');
      ToastUtil.showToast('Failed to update your plan.');
      return null;
    }
  }

  PlatformSubscriptionModel? _handleTierResponse(Response response) {
    if (response.data['success'] == true) {
      ToastUtil.showToast(response.data['message'] ?? 'Plan updated');
      return PlatformSubscriptionModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    ToastUtil.showToast(response.data['message'] ?? 'Failed to update your plan.');
    return null;
  }

  Future<bool> cancelToStarter(String storeId, {bool atPeriodEnd = false}) async {
    try {
      final response = await _client.patch(ApiConstants.platformCancel(storeId, atPeriodEnd: atPeriodEnd), requiresAuth: true);
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'Plan updated');
        return true;
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to cancel plan.');
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ cancelToStarter error: $e');
      return false;
    }
  }

  Future<bool> subscribeToPosAddon(String storeId) async {
    try {
      final response = await _client.post(ApiConstants.platformPosAddonSubscribe(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'POS add-on activated');
        return true;
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to activate POS add-on.');
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ subscribeToPosAddon error: $e');
      return false;
    }
  }

  Future<bool> cancelPosAddon(String storeId) async {
    try {
      final response = await _client.patch(ApiConstants.platformPosAddonCancel(storeId), requiresAuth: true);
      if (response.data['success'] == true) {
        ToastUtil.showToast(response.data['message'] ?? 'POS add-on canceled');
        return true;
      }
      ToastUtil.showToast(response.data['message'] ?? 'Failed to cancel POS add-on.');
      return false;
    } on DioException catch (e) {
      DioExceptionHandler.handleDioException(e);
      return false;
    } catch (e) {
      debugPrint('❌ cancelPosAddon error: $e');
      return false;
    }
  }
}
