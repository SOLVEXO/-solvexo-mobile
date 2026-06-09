import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
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
        padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 52),
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: user?.profileImage != null
                ? ClipOval(
                    child: CommonImageView(
                      url: user!.profileImage,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                    ),
                  )
                : CustomText(
                    text: controller.initials,
                    fontSize: AppFontSize.large,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
          ),
          const SizedBox(height: 14),
          // Name + verified
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CustomText(
              text: user?.name ?? 'User',
              fontSize: AppFontSize.medium,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              textAlign: TextAlign.center,
            ),
            if (user?.isEmailVerified == true) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded, color: AppColors.blue, size: 18),
            ],
          ]),
          const SizedBox(height: 4),
          // Email
          CustomText(
            text: user?.email ?? '',
            fontSize: AppFontSize.verySmall,
            color: AppColors.white.withOpacity(0.75),
          ),
          const SizedBox(height: 10),
          // Buyer badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CustomText(
              text: 'Buyer Account',
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ]),
      );
    });
  }
}
