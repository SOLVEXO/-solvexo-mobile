import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/profile_icon.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile({
    super.key,
    this.onTap,
    this.isSubTitle = false,
    required this.iconName,
    required this.title,
    this.subTitle,
  });
  final Function()? onTap;
  final bool isSubTitle;
  final String? subTitle;
  final String iconName, title;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimen.allPadding,
          vertical: AppDimen.borderRadius,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        ),
        child: Row(
          spacing: AppDimen.borderRadius,
          children: [
            ProfileIcon(iconName: iconName),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.w500,
                ),
                isSubTitle
                    ? CustomText(text: subTitle ?? '', color: AppColors.gray600)
                    : SizedBox(height: 0),
              ],
            ),
            Spacer(),
            SvgIcon(assetName: AppIcons.chevronRight, size: 15),
          ],
        ),
        // child: ListTile(
        //   leading: ProfileIcon(iconName: iconName),
        //   title: CustomText(
        //     text: title,
        //     fontSize: AppFontSize.small2,
        //     fontWeight: FontWeight.w500,
        //   ),
        //   subtitle: isSubTitle
        //       ? CustomText(text: subTitle ?? '', color: AppColors.gray600)
        //       : null,
        //   trailing: SvgIcon(assetName: AppIcons.chevronRight, size: 20),
        // ),
      ),
    );
  }
}
