import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSignupCard extends StatelessWidget {
  const LoginSignupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        /// 🔥 Gradient background (premium look)
        gradient: AppColors.appbarGradient,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          /// 🔥 APP LOGO
          Container(
            height: 45,
            width: 45,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            ),
            child: CommonImageView(
              radius: BorderRadius.circular(AppDimen.borderRadius),
              imagePath: AppImages.logoImage, // 👈 your logo
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          /// 🔹 TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Login to continue",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.regular,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: "Access your cart & orders instantly",
                  color: Colors.white.withOpacity(0.9),
                  fontSize: AppFontSize.small2,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// 🔥 BUTTON
          Expanded(
            child: AppButton(
              onPressed: () => Get.toNamed(Routes.authTabView),
              label: "LOGIN",
            ),
          ),
        ],
      ),
    );
  }
}
