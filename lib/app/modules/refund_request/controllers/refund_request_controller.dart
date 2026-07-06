import 'package:book_store_app/app/components/custom_app_snack_bar.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Requests a return/refund for a delivered order —
/// `POST /api/orders/return-request/:orderId` (`orders.service.ts#returnRequest`).
/// The backend only accepts a single `reason` string (no photo evidence or
/// per-product breakdown), so the issue picker + optional note are combined
/// into one message rather than pretending attachments are supported.
class RefundRequestController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();

  Rx<RefundIssue?> selectedIssue = Rx<RefundIssue?>(null);
  final messageController = TextEditingController();

  RxBool isLoading = false.obs;

  bool get canContinue => selectedIssue.value != null;

  final issues = {
    RefundIssue.missing: "Missing product or accessories",
    RefundIssue.notReceived: "Package wasn't received",
    RefundIssue.notAsDescribed: "Product doesn't match description",
    RefundIssue.damaged: "Package or product is damaged",
    RefundIssue.wrongItem: "Wrong product was sent",
    RefundIssue.defective: "Product is defective or doesn't work",
    RefundIssue.counterfeit: "Suspected counterfeit",
  };

  Future<void> submitRefund(OrderModel order) async {
    if (!canContinue || isLoading.value) return;

    final issueLabel = issues[selectedIssue.value]!;
    final note = messageController.text.trim();
    final reason = note.isEmpty ? issueLabel : '$issueLabel — $note';

    try {
      isLoading.value = true;
      final success = await _orderRepo.requestReturn(orderId: order.orderId, reason: reason);

      if (success) {
        CustomAppSnackbar.success("Refund request submitted");
        Get.back();
      } else {
        CustomAppSnackbar.error("Refund request failed");
      }
    } catch (e) {
      CustomAppSnackbar.error("Failed to submit refund");
    } finally {
      isLoading.value = false;
    }
  }
}
