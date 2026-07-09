import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/base_view_screen.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

// NOTE (architecture): this screen's own `ChangePasswordController` is dead
// code (an empty GetxController) — all real logic lives on the shared
// `ProfileController`, found here rather than owned by this module. Left
// as-is for this pass since consolidating it needs a full trace of every
// place `ProfileController.changePassword` is called; flagging for a
// dedicated cleanup rather than risking an untested rewire.
class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    // Was `Get.put(ProfileController())` — since ProfileController is a
    // shared/permanent controller already created by the Profile screen,
    // `Get.put` here would replace that live instance every time this
    // screen builds. `Get.find` reuses it instead.
    final profileController = Get.find<ProfileController>();
    return BaseViewScreen(
      appBar: CustomAppBarTwo(title: "Change Password"),
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xs + 2),
      child: Form(
        key: profileController.passwordFormKey,
        child: Column(
          children: [
            Obx(
              () => CustomTextField(
                label: 'Current Password',
                controller: profileController.currentPasswordController,
                obscureText: !profileController.showCurrentPassword.value,
                suffixIcon: SvgIcon(
                  assetName: profileController.showCurrentPassword.value
                      ? AppIcons.showPassword
                      : AppIcons.hidePassword,
                  onTap: () => profileController.showCurrentPassword.toggle(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current password';
                  }
                  return null;
                },
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BaseRadius.sm),
                  topRight: Radius.circular(BaseRadius.sm),
                ),
                ispadding: true,
              ),
            ),
            Obx(
              () => CustomTextField(
                controller: profileController.newPasswordController,
                obscureText: !profileController.showNewPassword.value,
                label: "New Password",
                hintText: "Set New Password",
                suffixIcon: SvgIcon(
                  assetName: profileController.showNewPassword.value
                      ? AppIcons.showPassword
                      : AppIcons.hidePassword,
                  onTap: () => profileController.showNewPassword.toggle(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                ispadding: true,
              ),
            ),
            Obx(
              () => CustomTextField(
                controller: profileController.confirmPasswordController,
                obscureText: !profileController.showConfirmPassword.value,
                label: 'Confirm Password',
                suffixIcon: SvgIcon(
                  assetName: profileController.showConfirmPassword.value
                      ? AppIcons.showPassword
                      : AppIcons.hidePassword,
                  onTap: () => profileController.showConfirmPassword.toggle(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  }
                  if (value != profileController.newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(BaseRadius.sm),
                  bottomRight: Radius.circular(BaseRadius.sm),
                ),
              ),
            ),
            SizedBox(height: BaseSpacing.xs + 2),
            Obx(
              () => PrimaryButton(
                label: profileController.isUpdating.value ? "Updating..." : "Reset",
                isLoading: profileController.isUpdating.value,
                onPressed: profileController.isUpdating.value ? null : profileController.changePassword,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
