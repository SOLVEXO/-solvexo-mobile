// NOTE: no other file in the app references `ProfileCard` — appears to be
// dead/superseded code (ProfileView uses `ProfileHero` instead). Left in
// place rather than deleted since deletion wasn't requested, but flagging
// this for a cleanup pass; fixed the logic bug below regardless in case
// it's revived.
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Obx(() {
      final user = controller.user.value;

      if (user == null) {
        // Was checked twice with the identical condition — the second
        // branch (this "Failed to load / Retry" state) was unreachable
        // dead code because this first check already returns.
        return Center(child: LoginSignupCard());
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxl - 2, vertical: BaseSpacing.xl),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.appbarGradient,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        ),
        child: Column(
          spacing: BaseSpacing.xxs + 1,
          children: [
            user.profileImage == null
                ? CircleAvatar(
                    backgroundColor: AppColors.background,
                    radius: 30,
                    child: CustomText(
                      text: user.name[0].toUpperCase(),
                      color: AppColors.primaryColor,
                      fontSize: AppFontSize.veryLarge3,
                      fontWeight: FontWeight.w800,
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
              spacing: BaseSpacing.xxs + 1,
              children: [
                CustomText(
                  text: user.name,
                  color: AppColors.white,
                  fontSize: AppFontSize.small2,
                  fontWeight: FontWeight.w500,
                ),
                user.isEmailVerified
                    ? const Icon(Icons.verified, color: AppColors.blue, size: 18)
                    : const SizedBox(),
              ],
            ),
            Semantics(
              button: true,
              label: 'Edit profile',
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.editProfileView),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs - 1),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5, color: AppColors.white),
                    borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: BaseSpacing.xs,
                    children: [
                      CustomText(
                        text: 'Edit Profile',
                        color: AppColors.white,
                        fontSize: AppFontSize.extraSmall,
                      ),
                      SvgIcon(assetName: AppIcons.chevronRight, size: 20, color: AppColors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
