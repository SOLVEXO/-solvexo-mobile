import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/otp_controller.dart';

class OtpFieldBox extends StatelessWidget {
  final int index;
  const OtpFieldBox({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Was `Get.put(OtpController())` — recreated/replaced the controller on
    // every rebuild of every box (shake animation + resend timer reset each
    // time). The binding already provides one instance; just look it up.
    final controller = Get.find<OtpController>();
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.13,
      height: size.width * 0.13,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BaseRadius.md),
        color: AppColors.shimmerHighlight,
        border: Border.all(color: AppColors.greySwatch400, width: 1),
      ),
      child: TextField(
        controller: controller.textControllers[index],
        focusNode: controller.focusNodes[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        style: BaseTypography.headlineSmall(color: AppColors.black),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) => controller.onOtpInput(value, index),
      ),
    );
  }
}
