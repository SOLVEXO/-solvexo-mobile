import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerPasswordSecurityController extends GetxController {
  final RxBool isSaving = false.obs;
  final RxBool currentVisible = false.obs;
  final RxBool newVisible = false.obs;
  final RxBool confirmVisible = false.obs;

  late final TextEditingController currentCtrl;
  late final TextEditingController newCtrl;
  late final TextEditingController confirmCtrl;

  final RxString currentPwd = ''.obs;
  final RxString newPwd = ''.obs;
  final RxString confirmPwd = ''.obs;

  bool get canSave =>
      currentPwd.value.isNotEmpty &&
      newPwd.value.length >= 8 &&
      newPwd.value == confirmPwd.value;

  String? get strengthLabel {
    final p = newPwd.value;
    if (p.isEmpty) return null;
    if (p.length < 6) return 'Weak';
    if (p.length < 10) return 'Fair';
    final hasUpper = p.contains(RegExp(r'[A-Z]'));
    final hasNum = p.contains(RegExp(r'[0-9]'));
    final hasSpecial = p.contains(RegExp(r'[!@#\$&*~]'));
    if (hasUpper && hasNum && hasSpecial) return 'Strong';
    return 'Good';
  }

  Color get strengthColor {
    switch (strengthLabel) {
      case 'Weak': return const Color(0xFFEC3B3B);
      case 'Fair': return const Color(0xFFFF9500);
      case 'Good': return const Color(0xFF007AFF);
      case 'Strong': return const Color(0xFF34C759);
      default: return const Color(0xFFE8E8E8);
    }
  }

  Future<void> save() async {
    if (!canSave || isSaving.value) return;
    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isSaving.value = false;
    currentCtrl.clear(); newCtrl.clear(); confirmCtrl.clear();
    currentPwd.value = ''; newPwd.value = ''; confirmPwd.value = '';
    Get.back();
    Get.snackbar('', 'Password changed successfully!', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), borderRadius: 12);
  }

  @override
  void onInit() {
    super.onInit();
    currentCtrl = TextEditingController();
    newCtrl = TextEditingController();
    confirmCtrl = TextEditingController();
  }

  @override
  void onClose() {
    currentCtrl.dispose(); newCtrl.dispose(); confirmCtrl.dispose();
    super.onClose();
  }
}
