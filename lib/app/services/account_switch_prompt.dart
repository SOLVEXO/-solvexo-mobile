import 'dart:async';

import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/app/services/account_switch_service.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Confirm-then-switch flows for one email with a buyer AND a seller account
/// (docs Part B 1 + 5.1 #6; checklist #5).
class AccountSwitchPrompt {
  AccountSwitchPrompt._();

  static bool _busy = false;
  static bool _dialogOpen = false;

  /// Buyer-only API areas: a seller session gets 403 there (verified:
  /// GET /api/checkout/gift-options -> 403 "Access Denied: Insufficient role").
  static bool isBuyerOnlyPath(String path) =>
      path.contains('/api/checkout') ||
      path.contains('/api/payment') ||
      path.contains('/api/cart/buy-now');

  /// Called by the network layer on a 403 from a buyer-only area. Seller
  /// sessions get "Switch to your buyer account"; anyone else the API text.
  static Future<void> onBuyerOnly403(String fallbackMessage) async {
    if (await AppPreferences.getUserRole() != 'seller') {
      ToastUtil.showToast(fallbackMessage);
      return;
    }
    if (_dialogOpen) return;
    _dialogOpen = true;
    final go = await Get.dialog<bool>(
      AlertDialog(
        title: Text('This is your seller account'.tr),
        content: Text('Buying needs your buyer account. Switch to it to continue.'.tr),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Get.back(result: true),
            child: Text('Switch to your buyer account'.tr),
          ),
        ],
      ),
    );
    _dialogOpen = false;
    if (go == true) await toBuyer();
  }

  /// Seller → buyer: switch-to-buyer, or create-buyer-account when the
  /// person has none (free-trial-eligibility.hasBuyerAccount).
  static Future<void> toBuyer({AccountSwitchService? service}) async {
    if (_busy) return;
    _busy = true;
    try {
      final s = service ?? AccountSwitchService();
      final elig = await s.eligibility();
      final result = (elig == null || elig.hasBuyerAccount)
          ? await s.switchToBuyer()
          : await s.createBuyerAccount();
      if (!result.ok) {
        ToastUtil.showToast(result.message ?? 'Could not switch account.'.tr);
        return;
      }
      await AccountSwitchService.openFor(result.session!);
    } finally {
      _busy = false;
    }
  }

  /// Buyer → seller ("Sell on Edudeen"). Guests see the seller landing.
  static Future<void> toSeller({AccountSwitchService? service}) async {
    if (!await AppPreferences.isLoggedIn()) {
      Get.toNamed(Routes.welcome);
      return;
    }
    if (_busy) return;
    final s = service ?? AccountSwitchService();
    final elig = await s.eligibility();
    final hasSeller = elig?.hasSellerAccount ?? false;
    final go = await Get.dialog<bool>(
      AlertDialog(
        title: Text(hasSeller ? 'Open your seller account?'.tr : 'Start selling on Edudeen?'.tr),
        content: Text(hasSeller
            ? 'You will switch to your seller account. You can switch back any time.'.tr
            : 'A seller account will be made with this email and password. Then set up your store.'.tr),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Get.back(result: true),
            child: Text('Continue'.tr),
          ),
        ],
      ),
    );
    if (go != true) return;
    _busy = true;
    try {
      final result = await s.becomeSeller();
      if (!result.ok) {
        ToastUtil.showToast(result.message ?? 'Could not switch account.'.tr);
        return;
      }
      await AccountSwitchService.openFor(result.session!);
    } finally {
      _busy = false;
    }
  }
}
