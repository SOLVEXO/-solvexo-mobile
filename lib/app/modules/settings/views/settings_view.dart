import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/profile_icon.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Settings"),
      body: Padding(
        padding: EdgeInsets.only(top: AppDimen.bottomPadding),
        child: Column(
          children: List.generate(controller.settings.length, (index) {
            final item = controller.settings[index];

            return Padding(
              padding: EdgeInsets.only(bottom: 3, left: 10, right: 10),

              child: GestureDetector(
                onTap: item["ontap"],
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                  ),
                  child: ListTile(
                    leading: ProfileIcon(iconName: item["icon"]),
                    title: CustomText(
                      text: item["title"],
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.w500,
                    ),
                    trailing: SvgIcon(
                      assetName: AppIcons.chevronRight,
                      size: 20,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
