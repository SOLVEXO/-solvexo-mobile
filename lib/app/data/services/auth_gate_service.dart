import 'dart:async';

import 'package:book_store_app/app/components/login_prompt_sheet.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The single reusable "require auth" gate for guest-allowed screens that
/// still have a handful of protected actions (add to wishlist, message a
/// seller, view order history, ...). Call [requireAuth] at the top of the
/// action; if it resolves `true`, the calling code just continues on the
/// same line — no callback wiring needed at each call site, since the
/// awaiting function is still alive on the stack when the bottom sheet /
/// login screen resolves and simply resumes execution.
class AuthGateService {
  AuthGateService._();
  static final AuthGateService instance = AuthGateService._();

  Completer<bool>? _completer;
  String? _resumeRoute;

  bool get isAwaitingResume => _completer != null;

  Future<bool> requireAuth({
    String message = 'Login to continue with this action.',
  }) async {
    if (await AppPreferences.isLoggedIn()) return true;

    _resumeRoute = Get.currentRoute;
    _completer = Completer<bool>();
    var proceeding = false;

    await Get.bottomSheet(
      LoginPromptSheet(
        message: message,
        onLogin: () {
          proceeding = true;
          Get.back();
          _goToAuth(initialTab: 0);
        },
        onSignUp: () {
          proceeding = true;
          Get.back();
          _goToAuth(initialTab: 1);
        },
        onClose: () {
          proceeding = true;
          Get.back();
          resolveCancelled();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    // Swiped down / tapped the backdrop without picking an option.
    if (!proceeding) resolveCancelled();

    final result = await _completer!.future;
    _completer = null;
    return result;
  }

  Future<void> _goToAuth({required int initialTab}) async {
    // Guarded actions are always buyer-side — force the intent so a stale
    // 'seller' intent left over from a "Sell on Solvexo" visit never leaks
    // into this login/signup.
    await AppPreferences.saveIntentRole('user');
    Get.toNamed(Routes.authTabView, arguments: {'initialTab': initialTab});
  }

  /// Called by the auth flow once login/signup actually succeeds.
  void resolveSuccess() {
    final route = _resumeRoute;
    _resumeRoute = null;
    if (route != null) {
      Get.until((r) => r.settings.name == route);
    }
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(true);
    }
  }

  /// Called when the prompt is dismissed, or the auth flow is abandoned
  /// (back button) before completing.
  void resolveCancelled() {
    _resumeRoute = null;
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(false);
    }
  }
}
