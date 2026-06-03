import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerAppBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const SellerAppBar({
    super.key,
    this.title = 'Dashboard',
    this.subtitle = 'My Shop',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.appbarGradient),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: subtitle,
                  fontSize: AppFontSize.small2,
                  color: AppColors.background,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: title,
                  fontSize: AppFontSize.large,
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgIcon(assetName: AppIcons.notificationIcon),
          ),
          const SizedBox(width: 10),
          Obx(() {
            final profileController = Get.put(ProfileController());
            final name = profileController.user.value?.name ?? '';
            final initials = name.trim().isNotEmpty
                ? name
                      .trim()
                      .split(' ')
                      .map((w) => w[0])
                      .take(2)
                      .join()
                      .toUpperCase()
                : 'Me';
            return Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: initials,
                fontSize: 13,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ],
      ),
    );
  }
}
