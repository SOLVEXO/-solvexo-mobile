import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProductDangerZone extends StatelessWidget {
  final EditSellerProductController controller;

  const EditProductDangerZone({super.key, required this.controller});

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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimen.allPadding, 14, AppDimen.allPadding, 10,
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.red),
                SizedBox(width: 6),
                CustomText(
                  text: 'DANGER ZONE',
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                  letterSpacing: 0.6,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Padding(
            padding: const EdgeInsets.all(AppDimen.allPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightRed,
                    borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(
                              text: 'Delete this product',
                              fontSize: AppFontSize.verySmall,
                              fontWeight: FontWeight.w600,
                              color: AppColors.red,
                            ),
                            const SizedBox(height: 2),
                            CustomText(
                              text:
                                  'This action is permanent and cannot be undone.',
                              fontSize: AppFontSize.tiny,
                              color: AppColors.red.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => GestureDetector(
                    onTap: controller.isDeleting.value
                        ? null
                        : () => _confirmDelete(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.lightRed,
                        borderRadius: BorderRadius.circular(
                          AppDimen.serviceCountTileRadius,
                        ),
                        border: Border.all(
                          color: AppColors.red.withOpacity(0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: controller.isDeleting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.red,
                              ),
                            )
                          : const CustomText(
                              text: 'Delete Product',
                              fontSize: AppFontSize.verySmall,
                              fontWeight: FontWeight.w600,
                              color: AppColors.red,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        ),
        title: const CustomText(
          text: 'Delete Product?',
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        content: CustomText(
          text:
              'Are you sure you want to delete "${controller.product.name}"? This action cannot be undone.',
          fontSize: AppFontSize.verySmall,
          color: AppColors.grey,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const CustomText(
              text: 'Cancel',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.grey,
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.back();
              controller.deleteProduct();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(AppDimen.borderRadius),
              ),
              child: const CustomText(
                text: 'Delete',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
