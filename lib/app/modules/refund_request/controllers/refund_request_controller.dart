import 'dart:io';
import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/data/repositories/refund_request_repository.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RefundRequestController extends GetxController {
  final RefundRepository _refundRepo = RefundRepository();

  Rx<RefundIssue?> selectedIssue = Rx<RefundIssue?>(null);
  RxList<File> attachments = <File>[].obs;
  final messageController = TextEditingController();

  RxBool isLoading = false.obs;

  bool get canContinue => selectedIssue.value != null && attachments.isNotEmpty;

  final issues = {
    RefundIssue.missing: "Missing product or accessories",
    RefundIssue.notReceived: "Package wasn't received",
    RefundIssue.notAsDescribed: "Product doesn't match description",
    RefundIssue.damaged: "Package or product is damaged",
    RefundIssue.wrongItem: "Wrong product was sent",
    RefundIssue.defective: "Product is defective or doesn't work",
    RefundIssue.counterfeit: "Suspected counterfeit",
  };

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 80);

    if (file != null) {
      attachments.add(File(file.path));
    }
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  Future<void> submitRefund(OrderModel order) async {
    if (!canContinue) return;

    try {
      isLoading.value = true;

      // Extract all product IDs from the order automatically
      final productIds = order.orderItems
          .map((item) => item.productId)
          .toList();

      final refund = await _refundRepo.createRefund(
        orderId: order.id,
        productIds: productIds, // automatically included
        reason: selectedIssue.value!.apiValue, // use extension for backend
        description: messageController.text.trim(),
        attachments: attachments,
      );
      CustomAppSnackbar.success("Refund request submitted");
      Get.back();
      debugPrint("$refund");
      if (refund == null) {
        CustomAppSnackbar.error("Refund request Failed");
      }
    } catch (e) {
      CustomAppSnackbar.error("Failed to submit refund");
    } finally {
      isLoading.value = false;
    }
  }
}
