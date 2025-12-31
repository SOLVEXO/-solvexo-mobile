import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      child: Column(
        spacing: 5,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(AppImages.userImage),
          ),
          CustomText(
            text: "Jami Raza",
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
            fontSize: AppFontSize.large,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              CustomText(
                text: "(209) 555-0141",
                fontSize: AppFontSize.small,
                color: AppColors.gray600,
              ),
              Icon(Icons.verified, color: AppColors.blue),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              SvgIcon(assetName: AppIcons.coinIcon),
              CustomText(
                text: "200 Points",
                fontSize: AppFontSize.small,
                color: AppColors.gray600,
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(width: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                CustomText(text: "Edit Profile", fontSize: AppFontSize.regular),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
