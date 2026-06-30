import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpView extends StatelessWidget {
  SignUpView({super.key});

  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: authController.registerFormKey,
      child: SingleChildScrollView(
        key: const PageStorageKey("signup"),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Heading ───────────────────────────────────────────────────
            const CustomText(
              text: 'Create account',
              fontSize: AppFontSize.veryLarge,
              fontWeight: FontWeight.w800,
              color: AppColors.black2,
            ),
            const SizedBox(height: 2),
            const CustomText(
              text: 'Fill in the details below to get started',
              fontSize: AppFontSize.small,
              color: AppColors.grey,
            ),

            const SizedBox(height: 10),

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

            const SizedBox(height: 8),

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
                const SizedBox(width: 10),
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

            const SizedBox(height: 8),

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

            const SizedBox(height: 8),

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

            const SizedBox(height: 8),

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

            const SizedBox(height: 12),

            // ── Sign up button ────────────────────────────────────────────
            Obx(
              () => AppButton(
                label: authController.isLoading.value
                    ? 'Creating Account…'
                    : 'Create Account',
                onPressed: authController.isLoading.value
                    ? null
                    : authController.register,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
