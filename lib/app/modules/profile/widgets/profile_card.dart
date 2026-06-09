import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    final user = controller.user.value;
    // final hasImage =
    //     user.profileImage != null || controller.selectedImageFile.value != null;
    return Obx(() {
      if (controller.user.value == null) {
        return Center(child: LoginSignupCard());
      }

      if (controller.user.value == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: AppColors.greyDefault),
              SizedBox(height: AppDimen.bottomPadding),
              CustomText(text: 'Failed to load profile'),
              SizedBox(height: AppDimen.bottomPadding),
              AppButton(onPressed: controller.loadUserProfile, label: 'Retry'),
            ],
          ),
        );
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.appbarGradient,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        ),
        child: Column(
          spacing: 5,
          children: [
            user!.profileImage == null
                ? CircleAvatar(
                    backgroundColor: AppColors.background,
                    radius: 30,
                    child: CustomText(
                      text: user.name[0].toUpperCase(),
                      fontSize: AppFontSize.veryLarge,
                      color: AppColors.primaryColor,
                    ),
                  )
                : CommonImageView(
                    radius: BorderRadiusGeometry.circular(50),
                    url: user.profileImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.fill,
                  ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [
                CustomText(
                  text: user.name,
                  letterSpacing: 1,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: AppFontSize.medium,
                ),
                user.isEmailVerified
                    ? Icon(Icons.verified, color: AppColors.blue, size: 18)
                    : SizedBox(),
              ],
            ),
            // CustomText(
            //   text: user.phone ?? "please add phone number",
            //   fontSize: AppFontSize.small2,
            //   fontWeight: FontWeight.w500,
            //   color: AppColors.white,
            // ),
            // CustomText(
            //   text: user.email,
            //   fontSize: AppFontSize.small2,
            //   fontWeight: FontWeight.w500,
            //   color: AppColors.white,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   spacing: 5,
            //   children: [
            //     SvgIcon(assetName: AppIcons.coinIcon),
            //     CustomText(
            //       text: "200 Points",
            //       fontSize: AppFontSize.small,
            //       color: AppColors.white,
            //     ),
            //   ],
            // ),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.editProfileView),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: AppColors.white),
                  borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    CustomText(
                      text: "Edit Profile",
                      fontSize: AppFontSize.small,
                      color: AppColors.white,
                    ),
                    SvgIcon(
                      assetName: AppIcons.chevronRight,
                      size: AppFontSize.medium,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
