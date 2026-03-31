import 'dart:async';

import 'package:book_store_app/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:book_store_app/app/modules/payment/models/payment_method_model.dart';
import 'package:book_store_app/config/resources/app_sounds.dart';
import 'package:book_store_app/utils/sound_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentVerificationController extends GetxController {
  late final double amount;
  late final PaymentMethod method;

  final RxInt secondsLeft = 60.obs;
  final RxBool isExpired = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  final otpController = TextEditingController();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    amount = args["amount"];
    method = args["method"];

    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    secondsLeft.value = 60;
    isExpired.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft.value == 0) {
        timer.cancel();
        isExpired.value = true;
      } else {
        secondsLeft.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }

  void onOtpChanged(String value) {
    if (value.length == 6 && !isLoading.value && !isExpired.value) {
      verifyOtp();
    }
  }

  Future<void> verifyOtp() async {
    isLoading.value = true;
    hasError.value = false;

    await Future.delayed(const Duration(seconds: 2));

    if (otpController.text == "123456") {
      _onSuccess();
    } else {
      hasError.value = true;
    }

    isLoading.value = false;
  }

  final CheckoutController _checkoutController = Get.put(CheckoutController());
  void _onSuccess() {
    _checkoutController.placeOrder();
    SoundUtil.play(AppSounds.successSound);
  }
}
