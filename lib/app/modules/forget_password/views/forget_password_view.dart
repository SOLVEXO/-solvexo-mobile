import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/forget_password/controllers/forget_password_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ForgotPasswordController>();
    return BaseViewScreen(
      controller: controller,
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Forget Password"),
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md + 4, vertical: BaseSpacing.md + 4),
      child: Column(
        children: [
          Text(
            "Enter your email that exist on your account for reset your password, You will recieve OTP(One Time Password) on this email's inbox!",
            style: BaseTypography.bodyMedium(color: AppColors.gray600),
          ),
          SizedBox(height: BaseSpacing.md),
          CustomTextField(
            fillColor: AppColors.background,
            borderRadius: BorderRadius.circular(BaseRadius.md),
            hintText: "Enter your existing email!",
            controller: controller.emailController,
          ),
          SizedBox(height: BaseSpacing.md),
          Obx(
            () => PrimaryButton(
              label: controller.isLoading.value ? "Sending Otp..." : "Forget Password",
              isLoading: controller.isLoading.value,
              // Was unconditionally wired even while loading — could
              // double-fire the request on a fast double-tap.
              onPressed: controller.isLoading.value ? null : controller.sendOtp,
            ),
          ),
        ],
      ),
    );
  }
}
