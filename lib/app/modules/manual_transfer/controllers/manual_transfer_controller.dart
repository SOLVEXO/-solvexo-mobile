import 'dart:io';
import 'package:book_store_app/app/components/app_image_picker.dart';
import 'package:book_store_app/app/data/models/payment/manual_payment_model.dart';
import 'package:book_store_app/app/data/repositories/manual_transfer_repository.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManualTransferController extends GetxController {
  ManualTransferController({ManualTransferRepository? repository})
      : _repository = repository ?? ManualTransferRepository();

  final ManualTransferRepository _repository;

  String _checkoutId = '';
  double totalAmountUSD = 0;

  final Rx<ManualPaymentBankDetails> bankDetails = Rx<ManualPaymentBankDetails>(ManualPaymentBankDetails.empty);
  final RxBool isLoadingBankDetails = true.obs;

  final Rx<File?> proofImage = Rx<File?>(null);
  final referenceController = TextEditingController();
  final senderNameController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  /// Approximate only — the authoritative PKR amount is computed
  /// server-side (at whatever rate is current at submission time) and comes
  /// back on the created proof.
  double get approximateAmountPKR => totalAmountUSD * bankDetails.value.usdToPkrRate;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _checkoutId = args['checkoutId'] as String? ?? '';
    totalAmountUSD = (args['totalAmountUSD'] as num?)?.toDouble() ?? 0;
    _loadBankDetails();
  }

  Future<void> _loadBankDetails() async {
    isLoadingBankDetails.value = true;
    final details = await _repository.getBankDetails();
    if (details != null) bankDetails.value = details;
    isLoadingBankDetails.value = false;
  }

  void pickProofImage() {
    AppImagePicker.show(
      title: 'Upload Payment Proof',
      canRemove: proofImage.value != null,
      onRemove: () => proofImage.value = null,
      onPicked: (file) => proofImage.value = file,
    );
  }

  Future<void> submit() async {
    if (_checkoutId.isEmpty) return;
    if (proofImage.value == null) {
      ToastUtil.showToast('Please upload a screenshot or receipt of your transfer');
      return;
    }
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    try {
      final result = await _repository.submitPayment(
        checkoutId: _checkoutId,
        proofImage: proofImage.value!,
        transactionReference: referenceController.text.trim(),
        senderName: senderNameController.text.trim(),
      );

      if (result.success && result.proof != null) {
        if (Get.isRegistered<CartController>()) Get.find<CartController>().fetchCart();
        Get.offAllNamed(Routes.manualTransferStatusView, arguments: result.proof);
      } else {
        ToastUtil.showToast(result.message ?? 'Failed to submit payment proof');
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    referenceController.dispose();
    senderNameController.dispose();
    super.onClose();
  }
}
