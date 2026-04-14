import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/services/network_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoSignalView extends StatelessWidget {
  const NoSignalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.white,
      width: double.infinity,
      child: Column(
        spacing: 30,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(assetName: AppIcons.noInternetIcon, size: 200),
          Column(
            children: [
              CustomText(
                text: "Ops!",
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.w800,
              ),
              CustomText(
                text: "No Internet",
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.w800,
              ),
              CustomText(
                text: "Please check your internet connection",
                fontSize: AppFontSize.regular,
              ),
            ],
          ),
          AppButton(
            label: "Try Again",
            onPressed: () {
              Get.find<NetworkController>().onInit();
            },
          ),
        ],
      ),
    );
  }
}
