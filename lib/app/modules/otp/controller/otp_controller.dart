import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_bottom_sheet.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final phoneNumber = "".obs;
  final otpLength = 6;

  late List<TextEditingController> textControllers;
  late List<FocusNode> focusNodes;

  RxBool resendAvailable = false.obs;
  RxInt timerSec = 15.obs;

  @override
  void onInit() {
    textControllers = List.generate(otpLength, (_) => TextEditingController());

    focusNodes = List.generate(otpLength, (_) => FocusNode());

    startTimer();
    super.onInit();
  }

  void startTimer() async {
    resendAvailable.value = false;
    timerSec.value = 15;

    for (int i = timerSec.value; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      timerSec.value = i - 1;
    }

    resendAvailable.value = true;
  }

  void resendCode() {
    if (resendAvailable.value == false) return;
    clearOtp();
    startTimer();
  }

  void clearOtp() {
    for (var c in textControllers) {
      c.clear();
    }
    focusNodes.first.requestFocus();
  }

  String get otpCode {
    String code = "";
    for (var c in textControllers) {
      code += c.text;
    }
    return code;
  }

  void onOtpInput(String value, int index, Size size) {
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
      return;
    }

    if (value.length == 1 && index < otpLength - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (index == otpLength - 1 && otpCode.length == otpLength) {
      submitOtp(size);
    }
  }

  void submitOtp(Size size) {
    if (otpCode.length != otpLength) {
      Get.snackbar("Error", "Invalid OTP");
      return;
    }

    // navigate or call API
    debugPrint("OTP is: $otpCode");

    Get.snackbar("Success", "OTP Verified!");
    Get.bottomSheet(
      backgroundColor: AppColors.white,
      CustomBottomSheet(
        height: size.height / 2,
        title: 'Verification Successfull',
        widget: Column(
          spacing: 10,
          children: [
            SizedBox(height: 10),
            SvgIcon(assetName: AppImages.userImage, size: 150),
            SizedBox(height: 10),
            CustomText(
              text: 'Congratulation!',
              fontSize: AppFontSize.large,
              fontWeight: FontWeight.w600,
            ),
            CustomText(
              text: 'Your verification has been successfull',
              fontSize: AppFontSize.small2,
            ),
            AppButton(
              label: "OK",
              onPressed: () {
                Get.offAllNamed(Routes.getNotified);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    for (var c in textControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
