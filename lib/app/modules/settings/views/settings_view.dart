import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/profile_tile.dart';
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
              child: ProfileTile(
                iconName: item["icon"],
                title: item["title"],
                onTap: item["ontap"],
              ),
            );
          }),
        ),
      ),
    );
  }
}
