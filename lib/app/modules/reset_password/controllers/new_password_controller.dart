import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';

class ResetPasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool showPassword = false.obs;
  RxBool showConfirmPassword = false.obs;

  late String email;
  late String otp;

  @override
  void onInit() {
    super.onInit();
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

  void togglePassword() => showPassword.value = !showPassword.value;
  void toggleConfirmPassword() => showConfirmPassword.value = !showConfirmPassword.value;

  // ================= RESET PASSWORD =================

  Future<void> resetPassword() async {
    if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      ToastUtil.showToast("Please fill all fields");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ToastUtil.showToast("Passwords do not match");
      return;
    }

    if (passwordController.text.length < 6) {
      ToastUtil.showToast("Password must be at least 6 characters");
      return;
    }

    isLoading.value = true;

    final intentRole = await AppPreferences.getIntentRole();
    final success = await _authRepository.resetPassword(
      email: email,
      otp: otp,
      newPassword: passwordController.text,
      role: intentRole ?? 'user',
    );

    isLoading.value = false;

    if (!success) {
      ToastUtil.showToast("Failed to reset password. OTP may have expired.");
      return;
    }

    ToastUtil.showToast("Password reset successfully. Please log in.");
    Get.offAllNamed(Routes.authTabView);
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
