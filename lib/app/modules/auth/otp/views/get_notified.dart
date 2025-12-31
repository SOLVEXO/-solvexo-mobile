import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/auth/otp/controller/notification_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetNotified extends StatelessWidget {
  const GetNotified({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(NotificationController());
    // final isTab = size.width > 600;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 22.0,
            right: 22.0,
            top: size.height / 12,
          ),
          child: Column(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Get notified about important stuff",
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.w800,
              ),
              CustomText(
                text: "We will notify you when",
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.w600,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primaryColor.withOpacity(0.2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    controller.notificationsAbout.length,
                    (index) {
                      final isLast =
                          index == controller.notificationsAbout.length - 1;
                      final programs = controller.notificationsAbout[index];
                      return customRow(
                        programs["icon"],
                        programs["notification"],
                        isLast,
                      );
                    },
                  ),
                ),
              ),
              Spacer(),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Later',
                      onPressed: () {
                        Get.offAllNamed(Routes.mainHome);
                      },
                      isOutlined: true,
                      textColor: AppColors.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      label: "Get notified",
                      onPressed: () {
                        Get.offAllNamed(Routes.mainHome);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customRow(String assetName, String text, bool islast) {
    return Padding(
      padding: EdgeInsets.only(bottom: islast ? 0 : 15.0),
      child: Row(
        spacing: 15,
        children: [
          SvgIcon(assetName: assetName),
          CustomText(text: text, fontSize: AppFontSize.small),
        ],
      ),
    );
  }
}
