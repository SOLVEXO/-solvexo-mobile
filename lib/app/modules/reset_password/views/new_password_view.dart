import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/new_password_controller.dart';

class NewPasswordView extends GetView<ResetPasswordController> {
  const NewPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: "Reset Password"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              color: AppColors.gray600,
              text: "Set your new Password!",
            ),
            const SizedBox(height: AppDimen.borderRadius),
            Obx(
              () => CustomTextField(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimen.borderRadius),
                  topRight: Radius.circular(AppDimen.borderRadius),
                ),
                obscureText: !controller.showPassword.value,
                hintText: "Set New Password",
                ispadding: true,
                suffixIcon: SvgIcon(
                  onTap: controller.togglePassword,
                  assetName: controller.showPassword.value
                      ? AppIcons.showPassword
                      : AppIcons.hidePassword,
                ),
                controller: controller.passwordController,
              ),
            ),
            Obx(
              () => CustomTextField(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppDimen.borderRadius),
                  bottomRight: Radius.circular(AppDimen.borderRadius),
                ),

                suffixIcon: SvgIcon(
                  onTap: controller.toggleConfirmPassword,
                  assetName: controller.showConfirmPassword.value
                      ? AppIcons.showPassword
                      : AppIcons.hidePassword,
                ),
                obscureText: !controller.showConfirmPassword.value,
                hintText: "Conform Password",
                controller: controller.confirmPasswordController,
              ),
            ),
            const SizedBox(height: AppDimen.borderRadius),
            Obx(
              () => AppButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.resetPassword,
                label: controller.isLoading.value
                    ? "Updating..."
                    : "Reset Password",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
