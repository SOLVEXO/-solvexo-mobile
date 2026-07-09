import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/new_password_controller.dart';

class NewPasswordView extends StatelessWidget {
  const NewPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResetPasswordController>();
    return BaseViewScreen(
      controller: controller,
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Reset Password"),
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md + 4, vertical: BaseSpacing.md + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Set your new Password!", style: BaseTypography.bodyMedium(color: AppColors.gray600)),
          SizedBox(height: BaseSpacing.md),
          Obx(
            () => CustomTextField(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(BaseRadius.md),
                topRight: Radius.circular(BaseRadius.md),
              ),
              fillColor: AppColors.background,
              obscureText: !controller.showPassword.value,
              hintText: "Set New Password",
              ispadding: true,
              suffixIcon: SvgIcon(
                onTap: controller.togglePassword,
                assetName: controller.showPassword.value
                    ? AppIcons.showPassword
                    : AppIcons.hidePassword,
                color: AppColors.gray600,
                size: 20,
              ),
              controller: controller.passwordController,
            ),
          ),
          Obx(
            () => CustomTextField(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(BaseRadius.md),
                bottomRight: Radius.circular(BaseRadius.md),
              ),
              fillColor: AppColors.background,
              suffixIcon: SvgIcon(
                onTap: controller.toggleConfirmPassword,
                assetName: controller.showConfirmPassword.value
                    ? AppIcons.showPassword
                    : AppIcons.hidePassword,
                color: AppColors.gray600,
                size: 20,
              ),
              obscureText: !controller.showConfirmPassword.value,
              // Was "Conform Password" — user-facing typo.
              hintText: "Confirm Password",
              controller: controller.confirmPasswordController,
            ),
          ),
          SizedBox(height: BaseSpacing.md),
          Obx(
            () => PrimaryButton(
              isLoading: controller.isLoading.value,
              onPressed: controller.isLoading.value ? null : controller.resetPassword,
              label: controller.isLoading.value ? "Updating..." : "Reset Password",
            ),
          ),
        ],
      ),
    );
  }
}
