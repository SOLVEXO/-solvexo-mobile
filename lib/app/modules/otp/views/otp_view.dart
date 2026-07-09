import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/otp/widgets/otp_field_boxes.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/otp_controller.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();
    final size = MediaQuery.of(context).size;

    return BaseViewScreen(
      controller: controller,
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "OTP Verification", centerTitle: true),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.07,
        vertical: size.height * 0.015,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: BaseSpacing.xxl + BaseSpacing.xxs),

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

          SizedBox(height: BaseSpacing.xl - BaseSpacing.xxs),

          /// Resend + Timer
          Obx(() {
            return AnimatedSwitcher(
              duration: BaseMotion.normal,
              child: controller.resendAvailable.value
                  ? GhostButton(label: "Resend OTP", onPressed: controller.resendCode)
                  : CustomText(
                      text: "Resend in ${controller.timerSec}s",
                      color: AppColors.grey,
                      fontSize: AppFontSize.extraSmall,
                    ),
            );
          }),

          SizedBox(height: BaseSpacing.xl + BaseSpacing.xxs),

          /// Details
          CustomText(
            text: "For your security reason, we need to ensure it's really you."
                "\nPlease enter the 6 digit code we sent to ${controller.email}"
                "\nthis code is expires in 10 minutes",
            textAlign: TextAlign.center,
            color: AppColors.greySwatch600,
            fontSize: AppFontSize.tiny,
          ),

          const Spacer(),

          /// Button
          Obx(() {
            return PrimaryButton(
              label: controller.isLoading.value ? "Verifying..." : "Verify",
              isLoading: controller.isLoading.value,
              onPressed: controller.isLoading.value ? null : controller.submitOtp,
            );
          }),

          SizedBox(height: size.height * 0.06),
        ],
      ),
    );
  }
}
