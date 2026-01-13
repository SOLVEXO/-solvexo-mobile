import 'package:book_store_app/app/components/auth_or_row.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/buttons/social_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey("signin"),
      child: Column(
        children: [
          /// Logo
          CustomText(
            text: "Home\nDecor.",
            fontSize: AppFontSize.veryLarge2,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryColor,
          ),

          const SizedBox(height: 30),

          SocialButton.google(() {}),
          const SizedBox(height: 12),
          SocialButton.facebook(() {}),
          const SizedBox(height: 12),
          SocialButton.apple(() {}),

          const SizedBox(height: 25),

          AuthOrRow(),

          const SizedBox(height: 20),

          /// Email / phone field
          CustomTextField(
            hintText: "Email Address or Phone number",
            isborder: true,
            borderRadius: BorderRadius.circular(12),
          ),

          const SizedBox(height: 20),

          AppButton(
            label: "Continue to Sign In",
            onPressed: () {
              Get.toNamed(Routes.otpView);
            },
          ),

          const SizedBox(height: 15),

          CustomText(
            text:
                "By continuing with sign in process, we may send you a one time code...",
            fontSize: AppFontSize.small2,
            color: AppColors.lightGrey,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
