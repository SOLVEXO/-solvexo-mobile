import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Form(
      key: authController.registerFormKey,
      child: SingleChildScrollView(
        key: const PageStorageKey("signup"),
        padding: EdgeInsets.fromLTRB(BaseSpacing.xl, BaseSpacing.xs, BaseSpacing.xl, BaseSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Heading ───────────────────────────────────────────────────
            Text('Create account', style: BaseTypography.headlineLarge(color: AppColors.black2)),
            SizedBox(height: BaseSpacing.xxs / 2),
            Text(
              'Fill in the details below to get started',
              style: BaseTypography.bodySmall(color: AppColors.grey),
            ),

            SizedBox(height: BaseSpacing.sm),

            // ── Email ─────────────────────────────────────────────────────
            CustomTextField(
              hintText: 'Email address',
              isborder: true,
              fillColor: AppColors.background,
              filled: true,
              prefixIcon: SvgIcon(
                assetName: AppIcons.emailIcon,
                color: AppColors.gray600,
              ),
              controller: authController.registerEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: authController.validateEmail,
            ),

            SizedBox(height: BaseSpacing.xs),

            // ── First + Last name ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: 'First name',
                    prefixIcon: SvgIcon(
                      assetName: AppIcons.profileIcon,
                      color: AppColors.gray600,
                    ),
                    isborder: true,
                    fillColor: AppColors.background,
                    filled: true,
                    controller: authController.registerFirstNameController,
                    validator: authController.validateName,
                  ),
                ),
                SizedBox(width: BaseSpacing.xs + 2),
                Expanded(
                  child: CustomTextField(
                    hintText: 'Last name',
                    prefixIcon: SvgIcon(
                      assetName: AppIcons.profileIcon,
                      color: AppColors.gray600,
                    ),
                    isborder: true,
                    fillColor: AppColors.background,
                    filled: true,
                    controller: authController.registerLastNameController,
                    validator: authController.validateName,
                  ),
                ),
              ],
            ),

            SizedBox(height: BaseSpacing.xs),

            // ── Phone ─────────────────────────────────────────────────────
            CustomTextField(
              hintText: 'Mobile number',
              isborder: true,
              fillColor: AppColors.background,
              filled: true,
              controller: authController.registerPhoneController,
              keyboardType: TextInputType.phone,
              validator: authController.validatePhone,
              prefixIcon: SvgIcon(
                assetName: AppIcons.phoneIcon,
                color: AppColors.lightGrey,
              ),
            ),

            SizedBox(height: BaseSpacing.xs),

            // ── Password ──────────────────────────────────────────────────
            Obx(
              () => CustomTextField(
                hintText: 'Password',
                isborder: true,
                fillColor: AppColors.background,
                filled: true,
                prefixIcon: SvgIcon(
                  assetName: AppIcons.lockPassword,
                  color: AppColors.gray600,
                ),
                controller: authController.registerPasswordController,
                obscureText: !authController.isPasswordVisible.value,
                validator: authController.validatePassword,
                suffixIcon: IconButton(
                  icon: SvgIcon(
                    assetName: authController.isPasswordVisible.value
                        ? AppIcons.hidePassword
                        : AppIcons.showPassword,
                    color: AppColors.grey,
                  ),
                  onPressed: authController.togglePasswordVisibility,
                ),
              ),
            ),

            SizedBox(height: BaseSpacing.xs),

            // ── Confirm password ──────────────────────────────────────────
            Obx(
              () => CustomTextField(
                hintText: 'Confirm password',
                isborder: true,
                fillColor: AppColors.background,
                filled: true,
                prefixIcon: SvgIcon(
                  assetName: AppIcons.lockPassword,
                  color: AppColors.gray600,
                ),
                controller: authController.registerConfirmPasswordController,
                obscureText: !authController.isConfirmPasswordVisible.value,
                validator: authController.validateConfirmPassword,
                suffixIcon: IconButton(
                  icon: SvgIcon(
                    assetName: authController.isConfirmPasswordVisible.value
                        ? AppIcons.hidePassword
                        : AppIcons.showPassword,
                    color: AppColors.grey,
                  ),
                  onPressed: authController.toggleConfirmPasswordVisibility,
                ),
              ),
            ),

            SizedBox(height: BaseSpacing.sm),

            // ── Sign up button ────────────────────────────────────────────
            Obx(
              () => PrimaryButton(
                label: authController.isLoading.value ? 'Creating Account…' : 'Create Account',
                isLoading: authController.isLoading.value,
                onPressed: authController.isLoading.value ? null : authController.register,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
