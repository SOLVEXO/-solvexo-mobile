import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
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
            title: controller.selectedCategoryIndex.value == 0
                ? controller.categories[0].name
                : controller
                      .categories[controller.selectedCategoryIndex.value - 0]
                      .name,
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
                                border: Border.all(
                                  width: 0.3,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.white,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimen.borderRadius,
                                ),
                              ),
                              child: CommonImageView(
                                url: item.image,

                                radius: BorderRadius.circular(
                                  AppDimen.borderRadius,
                                ),
                                width: 60,
                                height: 60,
                              ),
                            ),
                            const SizedBox(height: 6),
                            CustomText(
                              text: item.name,
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
                child: Obx(() {
                  final categoryObject = controller
                      .categories[controller.selectedCategoryIndex.value];
                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: controller.products.length,
                    itemBuilder: (_, i) {
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
                              CommonImageView(
                                radius: BorderRadius.circular(
                                  AppDimen.borderRadius,
                                ),
                                url: categoryObject.image,
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(width: 10),
                              CustomText(
                                text: categoryObject.name,
                                // text: categoryObject.name[i],
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
