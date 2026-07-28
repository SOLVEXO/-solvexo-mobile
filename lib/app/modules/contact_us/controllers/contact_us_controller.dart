import 'package:book_store_app/app/data/repositories/contact_repository.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactUsController extends GetxController {
  final ContactRepository _repo = ContactRepository();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final topicController = TextEditingController();
  final messageController = TextEditingController();

  final RxBool isSubmitting = false.obs;

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    try {
      final success = await _repo.submit(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        topic: topicController.text.trim(),
        message: messageController.text.trim(),
      );

      if (success) {
        ToastUtil.showToast(
          "Thanks for reaching out — we'll get back to you soon.",
        );
        Get.back();
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  String? validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Please enter $field';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    topicController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
