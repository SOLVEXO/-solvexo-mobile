import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginSignupCard extends StatelessWidget {
  const LoginSignupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BaseRadius.xxl - 6),
        gradient: AppColors.appbarGradient,
        boxShadow: BaseShadows.forLevel(BaseElevation.level3),
      ),
      child: Row(
        children: [
          // App logo
          Container(
            height: 45,
            width: 45,
            padding: EdgeInsets.all(BaseSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            ),
            child: CommonImageView(
              radius: BorderRadius.circular(AppDimen.borderRadius),
              imagePath: AppImages.logoImage,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(width: BaseSpacing.sm),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: "Login to continue",
                  color: AppColors.white,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: BaseSpacing.xxs / 2),
                CustomText(
                  text: "Access your cart & orders instantly",
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: AppFontSize.tiny,
                ),
              ],
            ),
          ),

          SizedBox(width: BaseSpacing.xs + 2),

          // Button
          Expanded(
            child: PrimaryButton(
              onPressed: () => Get.toNamed(Routes.authTabView),
              label: "LOGIN",
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}
