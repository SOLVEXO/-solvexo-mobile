import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/otp_controller.dart';

class OtpFieldBox extends StatelessWidget {
  final int index;
  const OtpFieldBox({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 0.13,
      height: size.width * 0.13,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.shimmerHighlight,
        border: Border.all(color: AppColors.greySwatch400, width: 1),
      ),
      child: TextField(
        controller: controller.textControllers[index],
        focusNode: controller.focusNodes[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) => controller.onOtpInput(value, index),
      ),
    );
  }
}
