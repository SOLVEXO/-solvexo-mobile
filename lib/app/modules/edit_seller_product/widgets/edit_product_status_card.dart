import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProductStatusCard extends StatelessWidget {
  final EditSellerProductController controller;

  const EditProductStatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppDimen.allPadding, 14, AppDimen.allPadding, 10),
            child: CustomText(
              text: 'Visibility',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w700,
              color: AppColors.grey,
              letterSpacing: 0.6,
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimen.allPadding,
              vertical: 14,
            ),
            child: Obx(
              () => Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: controller.isActive.value
                          ? AppColors.greenContainerInnerColor
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      controller.isActive.value
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      size: 18,
                      color: controller.isActive.value
                          ? AppColors.darkGreen
                          : AppColors.grey,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: controller.isActive.value ? 'Active' : 'Draft',
                          fontSize: AppFontSize.extraSmall,
                          fontWeight: FontWeight.w600,
                          color: controller.isActive.value
                              ? AppColors.darkGreen
                              : AppColors.black2,
                        ),
                        CustomText(
                          text: controller.isActive.value
                              ? 'Visible to buyers in your store'
                              : 'Hidden — only you can see it',
                          fontSize: AppFontSize.tiny,
                          color: AppColors.grey,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.isActive.value,
                    onChanged: (_) => controller.isActive.toggle(),
                    activeColor: AppColors.darkGreen,
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
