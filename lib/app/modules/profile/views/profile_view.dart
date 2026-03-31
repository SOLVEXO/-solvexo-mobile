import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/profile_icon.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/widgets/profile_bar.dart';
import 'package:book_store_app/app/modules/profile/widgets/profile_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  final controller = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: AppDimen.borderRadius,
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileBar(),
              ProfileCard(),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    itemCount: controller.options.length,
                    itemBuilder: (context, index) {
                      final item = controller.options[index];
                      final isLastItem = index == controller.options.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : AppDimen.bottomPadding,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            isLastItem
                                ? controller.logout()
                                : Get.toNamed(item["ontap"] as String);
                          },
                          child: Container(
                            padding: isLastItem
                                ? EdgeInsets.symmetric(vertical: 6)
                                : null,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimen.borderRadius,
                              ),
                            ),
                            child: ListTile(
                              leading: ProfileIcon(
                                iconName: item["icon"] as String,
                              ),
                              title: CustomText(
                                text: item["title"] as String,
                                fontSize: AppFontSize.small2,
                                fontWeight: FontWeight.w500,
                              ),
                              subtitle: isLastItem
                                  ? null
                                  : CustomText(
                                      text: item["subtitle"] as String,
                                      color: AppColors.gray600,
                                      fontSize: AppFontSize.verySmall,
                                    ),
                              trailing: SvgIcon(
                                assetName: AppIcons.chevronRight,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
