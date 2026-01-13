import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/otp/widgets/otp_fields.dart';
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 35),

            /// OTP Fields Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                controller.otpLength,
                (i) => OtpFieldBox(index: i),
              ),
            ),

            const SizedBox(height: 20),

            /// Resend + Timer
            Obx(() {
              return controller.resendAvailable.value
                  ? GestureDetector(
                      onTap: controller.resendCode,
                      child: const Text(
                        "Resend",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : CustomText(
                      text: "Resend in ${controller.timerSec}s",
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    );
            }),

            const SizedBox(height: 25),

            /// Details
            Obx(() {
              return CustomText(
                text:
                    "For your security reason, we need to ensure it's really you."
                    "\nPlease enter the 6 digit code we sent to ${controller.phoneNumber}"
                    "\nthis code is expires in 15 minutes",
                fontSize: 14,
                color: Colors.grey.shade600,
              );
            }),

            const Spacer(),

            /// Button
            AppButton(
              label: "Sign up",
              onPressed: () {
                controller.submitOtp(size);
              },
            ),

            SizedBox(height: size.height * 0.06),
          ],
        ),
      ),
    );
  }
}
