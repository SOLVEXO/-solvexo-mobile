import 'dart:async';

import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/cart_repository.dart';
import 'package:book_store_app/app/data/services/auth_gate_service.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/core/base/base_controller.dart';
import 'package:book_store_app/utils/otp_errors.dart';
import 'package:book_store_app/utils/toast_util.dart';

class OtpController extends BaseController {
  OtpController({
    AuthRepository? authRepository,
    CartRepository? cartRepository,
    String? otpType,
    String? email,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _cartRepository = cartRepository ?? CartRepository(),
       otpType = otpType ?? _readArg('type'),
       email = email ?? _readArg('email');

  static String _readArg(String key) {
    final args = Get.arguments;
    if (args is Map) return args[key] ?? '';
    return '';
  }

  final AuthRepository _authRepository;
  final CartRepository _cartRepository;

  AuthController get _authController {
    if (!Get.isRegistered<AuthController>()) Get.put(AuthController());
    return Get.find<AuthController>();
  }

  final int otpLength = 6;

  // Single controller — `PinCodeTextField` manages the individual boxes
  // itself (and, critically, correctly splits a pasted 6-digit code across
  // all of them; the old per-box `TextField` row truncated pasted text to
  // 1 character via `maxLength: 1` before `onChanged` ever saw it).
  final TextEditingController otpTextController = TextEditingController();

  // Drives the package's built-in shake + error-border animation — replaces
  // the hand-rolled `AnimationController`/`Transform.translate` that used
  // to live in the view.
  final StreamController<ErrorAnimationType> errorController =
      StreamController<ErrorAnimationType>.broadcast();

  RxBool resendAvailable = false.obs;
  RxInt timerSec = 60.obs;
  RxBool isResending = false.obs;
  RxString errorText = ''.obs;

  /// The current code can't be used any more (burned after 5 wrong tries, or
  /// expired). Input and Verify are disabled until a new code is requested.
  RxBool isLocked = false.obs;
  @override
  RxBool isLoading = false.obs;

  final String otpType;
  final String email;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  // ================= TIMER =================

  void startTimer() async {
    resendAvailable.value = false;
    timerSec.value = 60;

    for (int i = 60; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      timerSec.value = i - 1;
    }

    resendAvailable.value = true;
  }

  // ================= OTP HELPERS =================

  String get otpCode => otpTextController.text;

  void clearOtp() => otpTextController.clear();

  /// Clears the inline error the moment the user starts correcting the code.
  void onOtpChanged(String value) {
    if (errorText.value.isNotEmpty) errorText.value = '';
  }

  /// Only offer pin_code_fields' built-in "paste this code?" dialog for a
  /// clipboard value that actually looks like an OTP.
  bool canPasteText(String? text) {
    if (text == null) return false;
    final trimmed = text.trim();
    return trimmed.length == otpLength && int.tryParse(trimmed) != null;
  }

  // ================= VERIFY OTP =================

  /// [completedCode] is passed by `PinCodeTextField.onCompleted` — using it
  /// directly avoids a race where `otpTextController.text` hasn't caught up
  /// yet when the last digit lands.
  Future<void> submitOtp([String? completedCode]) async {
    if (isLocked.value) return;
    final code = completedCode ?? otpCode;
    if (code.length != otpLength) {
      ToastUtil.showToast("Please enter all 6 digits");
      return;
    }

    isLoading.value = true;

    if (otpType == "verify_email") {
      final intentRole = await AppPreferences.getIntentRole();

      final result = await _authRepository.verifyEmailOtp(
        email: email,
        otp: code,
        role: intentRole ?? 'user',
      );

      isLoading.value = false;

      final auth = result.auth;
      if (auth == null) {
        _handleFailedAttempt(result);
        return;
      }

      await AppPreferences.clearIntentRole();

      // Attach any profile photo picked during signup now that real tokens
      // exist. Never blocks navigation below if it fails.
      await _authController.finishProfileSetupAfterVerification(auth);

      // Buyer signup only — a seller account has no guest cart to merge.
      if (intentRole != 'seller') {
        await _cartRepository.mergeGuestCartIntoAccount();
        if (Get.isRegistered<CartController>()) {
          await Get.find<CartController>().refreshCart();
        }
      }

      if (AuthGateService.instance.isAwaitingResume) {
        // This signup was opened to resume a protected guest action — pop
        // back to where the guard fired instead of navigating away.
        AuthGateService.instance.resolveSuccess();
      } else if (intentRole == 'seller') {
        Get.offAllNamed(Routes.sellerOnboarding);
      } else {
        Get.offAllNamed(Routes.mainHome);
      }
    } else if (otpType == "password_reset") {
      // OTP is verified at the reset-password step by the backend
      isLoading.value = false;
      Get.toNamed(
        Routes.newPasswordView,
        arguments: {"email": email, "otp": code},
      );
    }
  }

  /// Uses the API's `code` / `attemptsLeft`: the 5th wrong try already comes
  /// back as `OTP_LOCKED`, so no client-side counting is needed.
  void _handleFailedAttempt(OtpVerifyResult result) {
    errorController.add(ErrorAnimationType.shake);
    clearOtp();

    switch (result.failure) {
      case OtpFailure.invalid:
        final left = result.attemptsLeft;
        errorText.value = left == null
            ? 'Incorrect code. Please try again.'
            : 'Incorrect code. $left ${left == 1 ? 'try' : 'tries'} left.';
        break;
      case OtpFailure.locked:
        _lock('Too many wrong attempts. This code is no longer valid.');
        break;
      case OtpFailure.expired:
        _lock('This code has expired.');
        break;
      case OtpFailure.other:
      case null:
        errorText.value =
            result.message ?? 'Could not verify the code. Please try again.';
    }
  }

  void _lock(String reason) {
    isLocked.value = true;
    errorText.value = '$reason Request a new code.';
    // No point making the user wait out the resend timer for a dead code.
    resendAvailable.value = true;
  }

  // ================= RESEND =================

  Future<void> resendCode() async {
    if (!resendAvailable.value || isResending.value) return;

    isResending.value = true;
    final intentRole = await AppPreferences.getIntentRole();
    // Password reset: the account is already verified, so resend-otp would be
    // refused ("User already verified"). Re-run forgot-password to get a new code.
    final ok = otpType == 'password_reset'
        ? await _authRepository.forgotPassword(email, role: intentRole ?? 'user')
        : await _authRepository.resendVerificationOtp(
            email,
            role: intentRole ?? 'user',
          );
    isResending.value = false;

    if (ok) {
      ToastUtil.showToast("OTP sent again");
      errorText.value = '';
      isLocked.value = false;
      clearOtp();
      startTimer();
    } else {
      ToastUtil.showToast("Failed to resend OTP");
    }
  }

  @override
  void onClose() {
    otpTextController.dispose();
    errorController.close();
    super.onClose();
  }
}
