import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/edit_seller_product/controllers/edit_seller_product_controller.dart';
import 'package:book_store_app/app/modules/edit_seller_product/widgets/edit_product_danger_zone.dart';
import 'package:book_store_app/app/modules/edit_seller_product/widgets/edit_product_form.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditSellerProductView extends StatelessWidget {
  EditSellerProductView({super.key});

  final EditSellerProductController controller =
      Get.put(EditSellerProductController());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Edit Product'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditProductForm(controller: controller),
            const SizedBox(height: 16),
            EditProductDangerZone(controller: controller),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(
        controller: controller,
        bottomInset: bottomInset,
      ),
    );
  }
}

// ── Save changes bottom bar ───────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final EditSellerProductController controller;
  final double bottomInset;

  const _SaveBar({required this.controller, required this.bottomInset});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.fromLTRB(
          AppDimen.allPadding,
          12,
          AppDimen.allPadding,
          12 + bottomInset,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: controller.canSave && !controller.isSaving.value
              ? controller.saveChanges
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              color: controller.canSave
                  ? AppColors.primaryColor
                  : AppColors.primaryColor.withOpacity(0.38),
              borderRadius:
                  BorderRadius.circular(AppDimen.serviceCountTileRadius),
            ),
            alignment: Alignment.center,
            child: controller.isSaving.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_rounded, color: AppColors.white, size: 18),
                      SizedBox(width: 8),
                      CustomText(
                        text: 'Save Changes',
                        fontSize: AppFontSize.small2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
