import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/profile_icon.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileBar extends StatelessWidget {
  const ProfileBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppDimen.allPadding,
        horizontal: AppDimen.allPadding,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: "Profile",
            letterSpacing: 2,
            // color: AppColors.white,
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.w600,
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.SETTINGS),
            child: ProfileIcon(iconName: AppIcons.settingIcon),
          ),
        ],
      ),
    );
  }
}
