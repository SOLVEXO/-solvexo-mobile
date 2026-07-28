import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/contact_us/controllers/contact_us_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactUsView extends StatelessWidget {
  ContactUsView({super.key});

  final controller = Get.put(ContactUsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomAppBarTwo(title: 'Contact Us'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(BaseSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text:
                        "Have a question or need help? Send us a message "
                        "and our support team will get back to you, usually "
                        "within 24 hours.",
                    fontSize: AppFontSize.small2,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: BaseSpacing.lg),
                  _ContactFormCard(controller: controller),
                  SizedBox(height: BaseSpacing.xl),
                  Obx(
                    () => PrimaryButton(
                      label: 'Send Message',
                      isLoading: controller.isSubmitting.value,
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactFormCard extends StatelessWidget {
  final ContactUsController controller;
  const _ContactFormCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(BaseSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseSpacing.md),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              hintText: 'Your Name',
              controller: controller.nameController,
              validator: (v) => controller.validateRequired(v, 'your name'),
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
              hintText: 'Topic (e.g. Order or delivery)',
              controller: controller.topicController,
              validator: (v) => controller.validateRequired(v, 'a topic'),
              ispadding: true,
              prefixIcon: const SvgIcon(
                assetName: AppIcons.messageIcon,
                color: AppColors.grey,
              ),
            ),
            CustomTextField(
              hintText: "Tell us a bit about what's going on…",
              controller: controller.messageController,
              validator: (v) => controller.validateRequired(v, 'a message'),
              maxLines: 5,
              prefixIcon: const SvgIcon(
                assetName: AppIcons.messageIcon,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
