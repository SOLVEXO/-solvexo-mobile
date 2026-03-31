import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';

class OtpController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();

  final int otpLength = 6;

  late List<TextEditingController> textControllers;
  late List<FocusNode> focusNodes;

  RxBool resendAvailable = false.obs;
  RxInt timerSec = 15.obs;
  RxBool isLoading = false.obs;

  final String otpType = Get.arguments['type'] ?? "";
  final String email = Get.arguments['email'] ?? "";

  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  @override
  void onInit() {
    super.onInit();

    textControllers = List.generate(otpLength, (_) => TextEditingController());

    focusNodes = List.generate(otpLength, (_) => FocusNode());

    // 🔥 Shake animation for errors
    shakeController = AnimationController(
      vsync: this,
      duration: 300.milliseconds,
    );

    shakeAnimation = Tween(begin: 0.0, end: 12.0).animate(shakeController);

    startTimer();
  }

  // ================= TIMER =================

  void startTimer() async {
    resendAvailable.value = false;
    timerSec.value = 15;

    for (int i = 15; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      timerSec.value = i - 1;
    }

    resendAvailable.value = true;
  }

  // ================= OTP HELPERS =================

  String get otpCode => textControllers.map((e) => e.text).join();

  void clearOtp() {
    for (var c in textControllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
  }

  // 🔥 Paste full OTP support
  void handlePaste(String value) {
    if (value.length != otpLength) return;

    for (int i = 0; i < otpLength; i++) {
      textControllers[i].text = value[i];
    }

    submitOtp();
  }

  // ================= INPUT HANDLING =================

  void onOtpInput(String value, int index) {
    if (value.length > 1) {
      handlePaste(value);
      return;
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
      return;
    }

    if (value.length == 1 && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    // Auto verify
    if (index == otpLength - 1 && otpCode.length == otpLength) {
      submitOtp();
    }
  }

  // ================= VERIFY OTP =================

  Future<void> submitOtp() async {
    if (otpCode.length != otpLength) {
      ToastUtil.showToast("Invalid OTP");
      return;
    }

    isLoading.value = true;

    if (otpType == "verify_email") {
      final auth = await _authRepository.verifyEmailOtp(
        email: email,
        otp: otpCode,
      );

      isLoading.value = false;

      if (auth != null) {
        Get.offAllNamed(Routes.mainHome);
      } else {
        ToastUtil.showToast("Invalid OTP");
      }
    } else if (otpType == "password_reset") {
      Get.toNamed(
        Routes.newPasswordView,
        arguments: {"email": email, "otp": otpCode},
      );

      isLoading.value = false;
    }
  }

  // ================= RESEND =================

  Future<void> resendCode() async {
    if (!resendAvailable.value) return;

    final ok = await _authRepository.resendVerificationOtp(email);

    if (ok) {
      ToastUtil.showToast("OTP sent again");
      clearOtp();
      startTimer();
    } else {
      ToastUtil.showToast("Failed to resend OTP");
    }
  }

  // ================= ERROR ANIMATION =================

  void triggerError() async {
    await shakeController.forward();
    shakeController.reverse();
  }

  @override
  void onClose() {
    for (var c in textControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }

    shakeController.dispose();
    super.onClose();
  }
}
