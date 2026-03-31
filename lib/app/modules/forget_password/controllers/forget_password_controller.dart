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
    if (emailController.text.isEmpty) {
      ToastUtil.showToast("Enter email");
      return;
    }

    isLoading.value = true;

    final success = await _authRepository.forgotPassword(
      emailController.text.trim(),
    );

    isLoading.value = false;

    if (success) {
      ToastUtil.showToast("OTP sent to email");

      Get.toNamed(
        Routes.otpView,
        arguments: {
          'email': emailController.text.trim(),
          'type': 'password_reset',
        },
      );
    } else {
      ToastUtil.showToast("Failed to send OTP");
    }
  }
}
