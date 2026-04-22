import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryBreadcrumb extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryBreadcrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stack = controller.navigationStack;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        /// 🔥 IMPORTANT: horizontal scroll instead of Row
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              /// HOME CHIP
              GestureDetector(
                onTap: controller.clearSelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomText(
                    text: "Home",
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),

              /// STACK ITEMS
              ...stack.map((e) {
                return Row(
                  children: [
                    const SizedBox(width: 6),

                    /// CHEVRON
                    SvgIcon(
                      assetName: AppIcons.chevronRight,
                      size: 15,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 6),

                    /// CATEGORY CHIP
                    GestureDetector(
                      onTap: () {
                        controller.selectCategory(e);
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 140),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          text: e.name,
                          overflow: TextOverflow.ellipsis,

                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}
