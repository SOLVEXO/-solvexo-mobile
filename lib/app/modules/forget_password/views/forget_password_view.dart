import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/forget_password/controllers/forget_password_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:book_store_app/utils/dimens.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Column(
        children: [
          CustomText(
            color: AppColors.gray600,
            text:
                "Enter your email that exist on your account for reset your password, You will recieve OTP(One Time Password) on this email's inbox!",
          ),
          const SizedBox(height: AppDimen.borderRadius),
          CustomTextField(
            fillColor: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            hintText: "Enter your existing email!",
            controller: controller.emailController,
          ),
          const SizedBox(height: AppDimen.borderRadius),
          Obx(
            () => AppButton(
              label: controller.isLoading.value
                  ? "Sending Otp..."
                  : "Forget Password",
              onPressed: controller.sendOtp,
            ),
          ),
        ],
      ),
    );
  }
}
