import 'package:book_store_app/app/components/auth_or_row.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/buttons/social_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Email Field
            CustomTextField(
              hintText: "Enter email address",
              isborder: true,
              controller: authController.registerEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: authController.validateEmail,
            ),

            const SizedBox(height: AppDimen.borderRadius),

            // First Name and Last Name
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    hintText: "First name",
                    isborder: true,
                    controller: authController.registerFirstNameController,
                    validator: authController.validateName,
                  ),
                ),
                const SizedBox(width: AppDimen.borderRadius),
                Expanded(
                  child: CustomTextField(
                    hintText: "Last name",
                    isborder: true,
                    controller: authController.registerLastNameController,
                    validator: authController.validateName,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimen.borderRadius),

            // Phone Number Field
            CustomTextField(
              hintText: "Input mobile number",
              isborder: true,
              controller: authController.registerPhoneController,
              keyboardType: TextInputType.phone,
              validator: authController.validatePhone,
              prefixIcon: SvgIcon(
                assetName: AppIcons.phoneIcon,
                size: AppFontSize.verySmall,
                color: AppColors.lightGrey,
              ),
            ),

            const SizedBox(height: AppDimen.borderRadius),

            // Password Field
            Obx(
              () => CustomTextField(
                hintText: "Enter password",
                isborder: true,
                controller: authController.registerPasswordController,
                obscureText: !authController.isPasswordVisible.value,
                validator: authController.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    authController.isPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.lightGrey,
                  ),
                  onPressed: authController.togglePasswordVisibility,
                ),
              ),
            ),

            const SizedBox(height: AppDimen.borderRadius),

            // Confirm Password Field
            Obx(
              () => CustomTextField(
                hintText: "Confirm password",
                isborder: true,
                controller: authController.registerConfirmPasswordController,
                obscureText: !authController.isConfirmPasswordVisible.value,
                validator: authController.validateConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    authController.isConfirmPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.lightGrey,
                  ),
                  onPressed: authController.toggleConfirmPasswordVisibility,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Terms Text
            CustomText(
              text:
                  "By continuing with sign up process, you agree to our Terms & Conditions and Privacy Policy.",
              color: Colors.grey.shade700,
            ),

            SizedBox(height: AppDimen.borderRadius),

            // Sign Up Button
            Obx(
              () => AppButton(
                label: authController.isLoading.value
                    ? 'Signing Up...'
                    : 'Sign Up',
                onPressed: authController.isLoading.value
                    ? null
                    : () {
                        authController.register();
                      },
              ),
            ),

            SizedBox(height: AppDimen.borderRadius),

            const AuthOrRow(),

            const SizedBox(height: 25),

            // Social Login Buttons
            SocialButton.google(authController.signInWithGoogle),
            const SizedBox(height: AppDimen.borderRadius),
            SocialButton.facebook(authController.signInWithFacebook),
            const SizedBox(height: AppDimen.borderRadius),
            SocialButton.apple(authController.signInWithApple),
            SizedBox(height: AppDimen.borderRadius),
          ],
        ),
      ),
    );
  }
}
