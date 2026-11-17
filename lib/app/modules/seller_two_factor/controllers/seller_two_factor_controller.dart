import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TwoFAMethod { sms, email, app }

class SellerTwoFactorController extends GetxController {
  final RxBool isEnabled = true.obs;
  final Rx<TwoFAMethod> selectedMethod = TwoFAMethod.email.obs;
  final RxBool isSaving = false.obs;

  static const methodLabels = {
    TwoFAMethod.sms: 'SMS',
    TwoFAMethod.email: 'Email',
    TwoFAMethod.app: 'Authenticator App',
  };

  static const methodDescriptions = {
    TwoFAMethod.sms: 'Receive a code by text message',
    TwoFAMethod.email: 'Receive a code by email',
    TwoFAMethod.app: 'Use Google / Microsoft Authenticator',
  };

  static const methodEmojis = {
    TwoFAMethod.sms: '📱',
    TwoFAMethod.email: '📧',
    TwoFAMethod.app: '🔐',
  };

  void selectMethod(TwoFAMethod method) => selectedMethod.value = method;

  Future<void> save() async {
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    isSaving.value = false;
    Get.back();
    Get.snackbar('', 'Two-factor auth settings saved!',
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12);
  }
}
