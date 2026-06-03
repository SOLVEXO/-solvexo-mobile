import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_settings/controllers/seller_settings_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsProfileCard extends StatelessWidget {
  final SellerSettingsController controller;

  const SettingsProfileCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimen.allPadding),
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _Avatar(initials: controller.initials),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: controller.name.value,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  const SizedBox(height: 3),
                  CustomText(
                    text: controller.email.value,
                    fontSize: AppFontSize.verySmall,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 6),
                  _PlanBadge(plan: controller.plan.value),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _EditButton(),
          ],
        ),
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String initials;

  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomText(
        text: initials,
        fontSize: AppFontSize.medium,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
}

// ── Plan badge ────────────────────────────────────────────────────────────────
class _PlanBadge extends StatelessWidget {
  final String plan;

  const _PlanBadge({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimen.draggableBorderRadius),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.25)),
      ),
      child: CustomText(
        text: plan,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryColor,
      ),
    );
  }
}

// ── Edit button ───────────────────────────────────────────────────────────────
class _EditButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: AppColors.lightGrey2),
        ),
        child: const CustomText(
          text: 'Edit',
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.black2,
        ),
      ),
    );
  }
}
