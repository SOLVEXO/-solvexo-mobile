import 'package:book_store_app/app/components/auth_or_row.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/buttons/social_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey("signup"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          customTextField("Enter email address", false),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: customTextField("First name", false)),
              const SizedBox(width: 16),
              Expanded(child: customTextField("Last name", false)),
            ],
          ),

          const SizedBox(height: 16),

          customTextField("Input mobile number", true),

          const SizedBox(height: 8),

          CustomText(
            text:
                "By continuing with sign in process, we may send you a one time SMS...",
            // fontSize: 12,
            color: Colors.grey.shade700,
          ),

          const SizedBox(height: 20),

          AppButton(
            label: 'Sign Up',
            onPressed: () {
              Get.toNamed(Routes.otpView);
            },
          ),

          const SizedBox(height: 20),

          AuthOrRow(),

          const SizedBox(height: 25),

          SocialButton.google(() {}),
          const SizedBox(height: 12),
          SocialButton.facebook(() {}),
          const SizedBox(height: 12),
          SocialButton.apple(() {}),
        ],
      ),
    );
  }

  Widget customTextField(String hint, bool isIcon) {
    return CustomTextField(
      hintText: hint,
      isborder: true,
      prefixIcon: isIcon
          ? SvgIcon(
              assetName: AppIcons.phoneIcon,
              size: AppFontSize.verySmall,
              color: AppColors.lightGrey,
            )
          : null,
    );
  }
}
