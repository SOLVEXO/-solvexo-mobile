import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/otp/widgets/otp_field_boxes.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/otp_controller.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomAppBarTwo(title: "OTP Verification", centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.07,
          vertical: size.height * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 35),

            /// OTP Fields Row
            AnimatedBuilder(
              animation: controller.shakeAnimation,
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(controller.shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Row(
                spacing: 3,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.otpLength,
                  (i) => OtpFieldBox(index: i),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Resend + Timer
            Obx(() {
              return AnimatedSwitcher(
                duration: 300.milliseconds,
                child: controller.resendAvailable.value
                    ? GestureDetector(
                        onTap: controller.resendCode,
                        child: const CustomText(
                          text: "Resend OTP",
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        "Resend in ${controller.timerSec}s",
                        style: const TextStyle(color: Colors.grey),
                      ),
              );
            }),

            const SizedBox(height: 25),

            /// Details
            CustomText(
              text:
                  "For your security reason, we need to ensure it's really you."
                  "\nPlease enter the 6 digit code we sent to ${controller.email}"
                  "\nthis code is expires in 10 minutes",
              fontSize: 14,
              textAlign: TextAlign.center,
              color: Colors.grey.shade600,
            ),

            const Spacer(),

            /// Button
            Obx(() {
              return AppButton(
                label: controller.isLoading.value ? "Verifying..." : "Verify",
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitOtp,
              );
            }),

            SizedBox(height: size.height * 0.06),
          ],
        ),
      ),
    );
  }
}
