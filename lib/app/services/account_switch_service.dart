import 'dart:async';

import 'package:book_store_app/app/data/models/common_models/auth_response_model.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/notification/fcm_service.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// `GET /api/platform-plans/free-trial-eligibility` (verified 2026-11-17):
/// `{eligible, trialUsedAt, hasSellerAccount, hasBuyerAccount}`.
class AccountEligibility {
  const AccountEligibility({
    required this.eligible,
    required this.hasSellerAccount,
    required this.hasBuyerAccount,
    this.trialUsedAt,
  });

  final bool eligible;
  final bool hasSellerAccount;
  final bool hasBuyerAccount;
  final DateTime? trialUsedAt;

  factory AccountEligibility.fromJson(Map<String, dynamic> body) {
    final d = body['data'] is Map ? body['data'] as Map : body;
    return AccountEligibility(
      eligible: d['eligible'] == true,
      hasSellerAccount: d['hasSellerAccount'] == true,
      hasBuyerAccount: d['hasBuyerAccount'] == true,
      trialUsedAt: DateTime.tryParse(d['trialUsedAt']?.toString() ?? ''),
    );
  }
}

class SwitchResult {
  const SwitchResult.ok(this.session) : message = null;
  const SwitchResult.failed(this.message) : session = null;
  final AuthResponseModel? session;
  final String? message;
  bool get ok => session != null;
}

/// One email can own a buyer AND a seller account (docs Part B 1). These
/// calls hand back a session for the other role, stored like a login.
class AccountSwitchService {
  AccountSwitchService({BaseClient? client}) : _client = client ?? BaseClient();

  final BaseClient _client;

  Future<AccountEligibility?> eligibility() async {
    try {
      final res = await _client.get(ApiConstants.freeTrialEligibility, requiresAuth: true);
      return res.data is Map
          ? AccountEligibility.fromJson(Map<String, dynamic>.from(res.data as Map))
          : null;
    } catch (_) {
      return null;
    }
  }

  /// Seller → their buyer account (`"Buyer account ready"`).
  Future<SwitchResult> switchToBuyer() => _post(ApiConstants.switchToBuyer);

  /// Seller without a buyer account → creates one on the same email.
  Future<SwitchResult> createBuyerAccount() => _post(ApiConstants.createBuyerAccount);

  /// Buyer → their seller account (`"Seller account ready"`), created on the
  /// same email/password when there is none yet.
  Future<SwitchResult> becomeSeller() => _post(ApiConstants.becomeSeller);

  Future<SwitchResult> _post(String url) async {
    try {
      final res = await _client.post(url, data: const <String, dynamic>{}, requiresAuth: true);
      final body = res.data;
      if (body is Map && body['success'] == true) {
        final session = AuthResponseModel.fromJson(Map<String, dynamic>.from(body));
        await _store(session);
        return SwitchResult.ok(session);
      }
      return SwitchResult.failed(
          ApiError.fromBody(body) ?? 'Could not switch account. Please try again.');
    } on DioException catch (e) {
      return SwitchResult.failed(ApiError.fromBody(e.response?.data) ??
          'Could not switch account. Please try again.');
    } catch (_) {
      return const SwitchResult.failed('Could not switch account. Please try again.');
    }
  }

  Future<void> _store(AuthResponseModel s) async {
    await AppPreferences.setTokens(
      accessToken: s.token.accessToken,
      refreshToken: s.token.refreshToken,
    );
    await AppPreferences.saveUserData(
      userId: s.user.id,
      name: s.user.name,
      email: s.user.email,
      role: s.user.role,
    );
    await AppPreferences.saveIntentRole(s.user.role);
    // Push registration must never undo a successful switch.
    try {
      unawaited(FcmService().init().catchError((_) => null));
    } catch (_) {}
  }

  /// After a switch: open the side of the app that matches the new role.
  static Future<void> openFor(AuthResponseModel s) async {
    if (s.user.role == 'seller') {
      Get.offAllNamed(Routes.sellerStores);
      return;
    }
    if (Get.isRegistered<CartController>()) {
      unawaited(Get.find<CartController>().refreshCart());
    }
    Get.offAllNamed(Routes.mainHome);
  }
}
