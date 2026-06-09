import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ToastUtil.showToast("Please enter your email");
      return;
    }

    isLoading.value = true;

    final intentRole = await AppPreferences.getIntentRole();
    final success = await _authRepository.forgotPassword(
      email,
      role: intentRole ?? 'user',
    );

    isLoading.value = false;

    if (success) {
      ToastUtil.showToast("OTP sent to email");

      Get.toNamed(
        Routes.otpView,
        arguments: {
          'email': email,
          'type': 'password_reset',
        },
      );
    } else {
      ToastUtil.showToast("Failed to send OTP. Check your email and try again.");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
