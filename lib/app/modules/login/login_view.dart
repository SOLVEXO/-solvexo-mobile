import 'package:book_store_app/app/components/auth_or_row.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/buttons/social_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/auth/controller/auth_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey("signin"),
      child: Column(
        children: [
          /// Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              CommonImageView(imagePath: AppImages.logoImage, width: 50),
              CustomText(
                text: "SOLVEXO",
                fontSize: AppFontSize.veryLarge,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
                color: AppColors.black,
              ),
            ],
          ),

          SizedBox(height: 20),

          /// Email / phone field
          Form(
            key: authController.loginFormKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: authController.loginEmailController,
                  hintText: "Email Address or Phone number",
                  isborder: true,
                  borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                ),

                const SizedBox(height: AppDimen.borderRadius),
                Obx(
                  () => CustomTextField(
                    hintText: "Enter password",
                    isborder: true,
                    controller: authController.loginPasswordController,
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
              ],
            ),
          ),
          SizedBox(height: AppDimen.borderRadius),
          Obx(
            () => AppButton(
              label: authController.isLoading.value ? 'Logging In...' : 'Login',
              onPressed: authController.isLoading.value
                  ? null
                  : () {
                      authController.login();
                    },
            ),
          ),
          const SizedBox(height: AppDimen.borderRadius),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.forgetPasswordView);
            },
            child: CustomText(
              text: "Forgot Password?",
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
              fontSize: AppFontSize.small2,
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(height: AppDimen.borderRadius),
          CustomText(
            text:
                "By continuing with sign in process, we may send you a one time code...",
            fontSize: AppFontSize.small2,
            color: AppColors.lightGrey,
          ),
          const SizedBox(height: AppDimen.borderRadius),
          const AuthOrRow(),
          const SizedBox(height: AppDimen.borderRadius),
          // Social Login Buttons
          SocialButton.google(authController.signInWithGoogle),
          const SizedBox(height: AppDimen.borderRadius),
          SocialButton.facebook(authController.signInWithFacebook),
          const SizedBox(height: AppDimen.borderRadius),
          SocialButton.apple(authController.signInWithApple),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
