import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
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
        padding: const EdgeInsets.all(16),
        itemCount: controller.searchResults.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final category = controller.searchResults[index];

          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: AppColors.white,
            leading: const Icon(Icons.category),
            title: Text(category.name),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(
                // '/products',
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
      child: Text(text, style: TextStyle(color: AppColors.greySwatch600)),
    );
  }
}
