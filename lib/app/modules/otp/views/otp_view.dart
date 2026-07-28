import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../controller/otp_controller.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();
    final size = MediaQuery.of(context).size;
    final boxSize = size.width * 0.13;

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

          /// OTP field — a single `PinCodeTextField`, not 6 separate
          /// `TextField`s. It splits a pasted code across every box itself
          /// (the old per-box row truncated pasted text to 1 character via
          /// `maxLength: 1` before `onChanged` ever saw it), requests a
          /// numeric keyboard, and — via `enablePinAutofill`, on by default —
          /// wires the OS one-time-code autofill hint so iOS/Android can
          /// suggest the code as soon as it arrives.
          PinCodeTextField(
            appContext: context,
            length: controller.otpLength,
            controller: controller.otpTextController,
            // We own this controller (`OtpController.onClose` disposes it) —
            // without this, the package disposes it too when the widget
            // unmounts (e.g. on the `Get.offAllNamed` navigation right after
            // a successful verify), and GetX's later `onClose` double-dispose
            // crashes with "TextEditingController used after being disposed".
            autoDisposeControllers: false,
            autoFocus: true,
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
            errorAnimationController: controller.errorController,
            beforeTextPaste: controller.canPasteText,
            textStyle: BaseTypography.headlineSmall(color: AppColors.black),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(BaseRadius.md),
              fieldHeight: boxSize,
              fieldWidth: boxSize,
              activeFillColor: AppColors.shimmerHighlight,
              inactiveFillColor: AppColors.shimmerHighlight,
              selectedFillColor: AppColors.shimmerHighlight,
              activeColor: AppColors.primaryColor,
              selectedColor: AppColors.primaryColor,
              inactiveColor: AppColors.greySwatch400,
              errorBorderColor: AppColors.red,
            ),
            enableActiveFill: true,
            onChanged: controller.onOtpChanged,
            onCompleted: controller.submitOtp,
          ),

          // Inline error — the old flow only shook the boxes on a wrong code
          // with no explanation; this makes the failure legible.
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: controller.errorText.value.isEmpty
                  ? const SizedBox(height: BaseSpacing.md)
                  : Padding(
                      padding: EdgeInsets.only(top: BaseSpacing.xs),
                      child: CustomText(
                        text: controller.errorText.value,
                        color: AppColors.red,
                        fontSize: AppFontSize.tiny,
                      ),
                    ),
            ),
          ),

          SizedBox(height: BaseSpacing.md),

          /// Resend + Timer
          Obx(() {
            if (!controller.resendAvailable.value) {
              return CustomText(
                text: "Resend in ${controller.timerSec}s",
                color: AppColors.grey,
                fontSize: AppFontSize.extraSmall,
              );
            }
            return controller.isResending.value
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.primaryColor,
                      ),
                    ),
                  )
                : GhostButton(
                    label: "Resend OTP",
                    onPressed: controller.resendCode,
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
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.submitOtp(),
            );
          }),

          SizedBox(height: size.height * 0.06),
        ],
      ),
    );
  }
}
