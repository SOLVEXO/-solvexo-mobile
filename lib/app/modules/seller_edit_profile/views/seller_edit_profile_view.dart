import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_edit_profile/controllers/seller_edit_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerEditProfileView extends StatelessWidget {
  SellerEditProfileView({super.key});

  final SellerEditProfileController controller = Get.put(
    SellerEditProfileController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomAppBarTwo(title: 'Edit Profile'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    _AvatarHeader(controller: controller),
                    const SizedBox(height: 20),
                    _FormCard(controller: controller),
                    const SizedBox(height: 24),
                    _SaveButton(controller: controller),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Avatar header ─────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  final SellerEditProfileController controller;
  const _AvatarHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      decoration: BoxDecoration(gradient: AppColors.appbarGradient),
      child: Obx(() {
        final imageFile = controller.selectedImage.value;
        final profileUrl = controller.user.value?.profileImage;

        return Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: imageFile != null
                        ? Image.file(imageFile, fit: BoxFit.cover)
                        : profileUrl != null
                        ? CommonImageView(
                            url: profileUrl,
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          )
                        : _InitialsAvatar(initials: controller.initials),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.showImagePickerSheet,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                if (controller.isUploadingImage.value)
                  Positioned.fill(
                    child: ClipOval(
                      child: ColoredBox(
                        color: AppColors.black.withOpacity(0.4),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            CustomText(
              text: controller.user.value?.name ?? '',
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
            const SizedBox(height: 3),
            CustomText(
              text: controller.user.value?.email ?? '',
              fontSize: AppFontSize.verySmall,
              color: AppColors.white.withOpacity(0.8),
            ),
          ],
        );
      }),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor.withOpacity(0.2),
      alignment: Alignment.center,
      child: CustomText(
        text: initials,
        fontSize: AppFontSize.veryLarge,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }
}

// ── Form card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final SellerEditProfileController controller;
  const _FormCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Personal Information'),
            const SizedBox(height: 12),
            CustomTextField(
              hintText: 'Full Name',
              controller: controller.nameController,
              validator: controller.validateName,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimen.borderRadius),
                topRight: Radius.circular(AppDimen.borderRadius),
              ),
              ispadding: true,
              prefixIcon: const SvgIcon(
                assetName: AppIcons.profileIcon,
                color: AppColors.grey,
              ),
            ),
            CustomTextField(
              hintText: 'Email Address',
              controller: controller.emailController,
              validator: controller.validateEmail,
              keyboardType: TextInputType.emailAddress,
              ispadding: true,
              prefixIcon: const SvgIcon(
                assetName: AppIcons.emailIcon,
                color: AppColors.grey,
              ),
            ),
            CustomTextField(
              hintText: 'Phone Number (optional)',
              controller: controller.phoneController,
              validator: controller.validatePhone,
              keyboardType: TextInputType.phone,
              ispadding: true,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppDimen.borderRadius),
                bottomRight: Radius.circular(AppDimen.borderRadius),
              ),
              prefixIcon: const SvgIcon(
                assetName: AppIcons.phoneIcon,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: label,
      fontSize: AppFontSize.verySmall,
      fontWeight: FontWeight.w700,
      color: AppColors.black2,
    );
  }
}

// ── Save button ───────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final SellerEditProfileController controller;
  const _SaveButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
        child: AppButton(
          label: controller.isUpdating.value ? 'Saving...' : 'Save Changes',
          onPressed: controller.isUpdating.value
              ? null
              : controller.saveProfile,
        ),
      ),
    );
  }
}
