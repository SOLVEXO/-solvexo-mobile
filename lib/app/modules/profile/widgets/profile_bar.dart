// NOTE: no other file in the app references `ProfileBar` — appears to be
// dead/superseded code. Migrated regardless in case it's revived.
import 'package:book_store_app/app/components/profile_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileBar extends StatelessWidget {
  const ProfileBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppDimen.allPadding, horizontal: AppDimen.allPadding),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Profile",
            style: BaseTypography.titleMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w600, letterSpacing: 2),
          ),
          Semantics(
            button: true,
            label: 'Settings',
            child: GestureDetector(
              onTap: () => Get.toNamed(Routes.SETTINGS),
              child: ProfileIcon(iconName: AppIcons.settingIcon),
            ),
          ),
        ],
      ),
    );
  }
}
