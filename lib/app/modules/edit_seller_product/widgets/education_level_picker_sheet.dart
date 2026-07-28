import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Tier-1 education-level picker for the edit-product flow. Mirrors the
/// add-product flow's `EducationLevelPickerSheet`.
class EditEducationLevelPickerSheet extends StatelessWidget {
  final EditSellerProductController controller;
  const EditEducationLevelPickerSheet({super.key, required this.controller});

  static void show(BuildContext context, EditSellerProductController controller) {
    Get.bottomSheet(
      EditEducationLevelPickerSheet(controller: controller),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      text: 'Education Level',
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.lightGrey2),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
              child: Obx(() => ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (final level in kEducationLevels)
                        _row(
                          label: level.label,
                          selected: controller.educationLevel.value == level.value,
                          onTap: () {
                            controller.selectEducationLevel(level.value);
                            Get.back();
                          },
                        ),
                    ],
                  )),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _row({required String label, required bool selected, required VoidCallback onTap}) {
    return ListTile(
      title: CustomText(
        text: label,
        fontSize: AppFontSize.verySmall,
        color: selected ? AppColors.primaryColor : AppColors.black2,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      trailing: selected ? const Icon(Icons.check_rounded, color: AppColors.primaryColor, size: 18) : null,
      onTap: onTap,
    );
  }
}
