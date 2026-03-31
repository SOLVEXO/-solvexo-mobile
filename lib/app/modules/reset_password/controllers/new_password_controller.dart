import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';

class ResetPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  RxBool isLoading = false.obs;
  RxBool showPassword = false.obs;
  RxBool showConfirmPassword = false.obs;

  late String email;
  late String otp;

  @override
  void onInit() {
    super.onInit();
    // coming from OTP screen
    email = Get.arguments["email"];
    otp = Get.arguments["otp"];
  }

  // ================= VALIDATION =================

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter new password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  void togglePassword() {
    showPassword.value = !showPassword.value;
  }

  void toggleConfirmPassword() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  // ================= RESET PASSWORD =================

  Future<void> resetPassword() async {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ToastUtil.showToast("Please fill all fields");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ToastUtil.showToast("Passwords do not match");
      return;
    }

    isLoading.value = true;

    final success = await _authRepository.resetPassword(
      email: email,
      otp: otp,
      newPassword: passwordController.text,
    );

    isLoading.value = false;

    if (success) {
      ToastUtil.showToast("Password reset successful");

      // back to login
      Get.offAllNamed(Routes.authTabView);
    } else {
      ToastUtil.showToast("Failed to reset password");
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
