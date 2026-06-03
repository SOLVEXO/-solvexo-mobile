import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  ChangePasswordView({super.key});
  final profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Change Password"),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
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
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              AppButton(
                iconWidget: profileController.isUpdating.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.white),
                        ),
                      )
                    : null,
                label: profileController.isUpdating.value ? "" : "Reset",
                onPressed: profileController.isUpdating.value
                    ? null
                    : profileController.changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
