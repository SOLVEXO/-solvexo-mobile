import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Optional subcategory picker for the add-product flow — select one of the
/// store's main-category subcategories, or add a new one on the fly. Main
/// categories stay admin-only; this only ever nests one level under the
/// store's existing main category (enforced server-side too).
class SubcategoryPickerSheet extends StatelessWidget {
  final AddSellerProductController controller;
  const SubcategoryPickerSheet({super.key, required this.controller});

  static void show(BuildContext context, AddSellerProductController controller) {
    Get.bottomSheet(
      SubcategoryPickerSheet(controller: controller),
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
                      text: 'Subcategory',
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black2,
                    ),
                  ),
                  CustomText(text: '(optional)', fontSize: AppFontSize.tiny, color: AppColors.grey),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.lightGrey2),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: Obx(() {
                if (controller.isLoadingSubcategories.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                      ),
                    ),
                  );
                }

                final items = controller.subcategories;
                return ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _row(
                      label: 'None',
                      selected: controller.selectedSubCategoryId.value == null,
                      onTap: () {
                        controller.selectSubCategory(null);
                        Get.back();
                      },
                    ),
                    for (final c in items)
                      _row(
                        label: c.name,
                        selected: controller.selectedSubCategoryId.value == c.id,
                        onTap: () {
                          controller.selectSubCategory(c.id);
                          Get.back();
                        },
                      ),
                  ],
                );
              }),
            ),
            const Divider(height: 1, color: AppColors.lightGrey2),
            InkWell(
              onTap: () => _showAddDialog(context),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primaryColor),
                    SizedBox(width: 10),
                    CustomText(
                      text: 'Add New Subcategory',
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
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

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    CustomConfirmDialog.show(
      context,
      title: 'Add Subcategory',
      confirmLabel: 'Add',
      contentBuilder: (_) => CustomTextField(
        controller: nameCtrl,
        hintText: 'e.g. Wireless Headphones',
        isborder: true,
      ),
      onConfirm: () async {
        final name = nameCtrl.text.trim();
        if (name.isEmpty) return;
        final created = await controller.createSubcategory(name);
        // Close the picker sheet too once a new subcategory is created and
        // auto-selected — nothing left to pick.
        if (created != null) Get.back();
      },
    );
  }
}
