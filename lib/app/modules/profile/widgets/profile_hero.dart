import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileHero extends StatelessWidget {
  final ProfileController controller;
  const ProfileHero({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Obx(() {
      final user = controller.user.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(BaseSpacing.xl, topPad + BaseSpacing.xl, BaseSpacing.xl, BaseSpacing.xxl + BaseSpacing.xxl),
        decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
        child: Column(children: [
          // Avatar
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
              boxShadow: BaseShadows.forLevel(BaseElevation.level4),
            ),
            alignment: Alignment.center,
            child: user?.profileImage != null
                ? ClipOval(
                    child: CommonImageView(url: user!.profileImage, width: 84, height: 84, fit: BoxFit.cover),
                  )
                : CustomText(
                    text: controller.initials,
                    color: AppColors.white,
                    fontSize: AppFontSize.veryLarge2,
                    fontWeight: FontWeight.bold,
                  ),
          ),
          SizedBox(height: BaseSpacing.sm + 2),
          // Name + verified
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CustomText(
              text: user?.name ?? 'User',
              color: AppColors.white,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            if (user?.isEmailVerified == true) ...[
              SizedBox(width: BaseSpacing.xxs + 2),
              const Icon(Icons.verified_rounded, color: AppColors.blue, size: 18),
            ],
          ]),
          SizedBox(height: BaseSpacing.xxs),
          // Email
          CustomText(
            text: user?.email ?? '',
            color: AppColors.white.withOpacity(0.75),
            fontSize: AppFontSize.tiny,
          ),
          SizedBox(height: BaseSpacing.xs + 2),
          // Buyer badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm + 2, vertical: BaseSpacing.xxs + 1),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(BaseRadius.pill),
            ),
            child: CustomText(
              text: 'Buyer Account',
              color: AppColors.white,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      );
    });
  }
}
