import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/widgets/profile_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  final controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Profile",
                letterSpacing: 2,
                fontSize: AppFontSize.large,
                fontWeight: FontWeight.w900,
              ),
              ProfileCard(),
              Expanded(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.options.length,
                  itemBuilder: (context, index) {
                    final item = controller.options[index];
                    final isLastItem = index == controller.options.length - 1;
                    return GestureDetector(
                      onTap: () {
                        isLastItem
                            ? Get.offAllNamed(item["ontap"] as String)
                            : Get.toNamed(item["ontap"] as String);
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: SvgIcon(
                              assetName: item["icon"] as String,
                              color: AppColors.primaryColor,
                              size: 26,
                            ),
                          ),
                          title: CustomText(
                            text: item["title"] as String,
                            fontSize: AppFontSize.small,
                            fontWeight: FontWeight.w600,
                          ),
                          subtitle: CustomText(
                            text: item["subtitle"] as String,
                          ),
                          trailing: SvgIcon(assetName: AppIcons.chevronRight),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
