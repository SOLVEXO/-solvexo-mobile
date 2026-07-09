import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategorySearchList extends StatelessWidget {
  final CategoryController controller;

  const CategorySearchList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return const CategoryEmptyView(text: "No categories found");
      }

      return ListView.separated(
        padding: EdgeInsets.all(BaseSpacing.md),
        itemCount: controller.searchResults.length,
        separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
        itemBuilder: (_, index) {
          final category = controller.searchResults[index];

          return ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseRadius.md)),
            tileColor: AppColors.white,
            leading: const Icon(Icons.category),
            title: CustomText(text: category.name, color: AppColors.black, fontSize: AppFontSize.small),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(
                Routes.subCategoryView,
                arguments: {
                  'categoryId': category.id,
                  'categoryName': category.name,
                },
              );
            },
          );
        },
      );
    });
  }
}

class CategoryEmptyView extends StatelessWidget {
  final String text;

  const CategoryEmptyView({super.key, this.text = "No categories available"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomText(text: text, color: AppColors.greySwatch600, fontSize: AppFontSize.tiny),
    );
  }
}
