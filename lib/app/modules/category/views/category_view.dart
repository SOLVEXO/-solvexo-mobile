import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,

      /// ------------------- APP BAR -------------------
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Obx(
          () => CustomAppBarTwo(
            title: controller
                .categories[controller.selectedCategoryIndex.value]
                .title,
          ),
        ),
      ),

      /// ------------------- BODY -------------------
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Row(
          children: [
            /// LEFT SIDE CATEGORY MENU
            Container(
              padding: EdgeInsets.only(right: 10),
              width: w * 0.25,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 15),
                itemCount: controller.categories.length,
                itemBuilder: (_, i) {
                  final item = controller.categories[i];

                  return Obx(() {
                    bool isSelected =
                        controller.selectedCategoryIndex.value == i;
                    return GestureDetector(
                      onTap: () => controller.selectedCategoryIndex.value = i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor.withOpacity(0.2)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: SvgIcon(assetName: item.icon, size: 60),
                            ),
                            const SizedBox(height: 6),
                            CustomText(
                              text: item.title,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : AppColors.textPrimary,
                              fontSize: AppFontSize.small2,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            /// RIGHT SIDE PRODUCT LIST
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: AppColors.background),
                child: Obx(
                  () => ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: controller
                        .categories[controller.selectedCategoryIndex.value]
                        .children
                        .length,
                    itemBuilder: (_, i) {
                      final categoryObject = controller
                          .categories[controller.selectedCategoryIndex.value];

                      return GestureDetector(
                        onTap: () => Get.toNamed(Routes.subCategoryView),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                offset: const Offset(0, 3),
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SvgIcon(assetName: categoryObject.icon, size: 60),
                              const SizedBox(width: 10),
                              CustomText(
                                text: categoryObject.children[i],
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
