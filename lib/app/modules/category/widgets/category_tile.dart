import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/models/category_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int level;

  const CategoryTile({super.key, required this.category, required this.level});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    final hasChildren = category.hasChildren;

    return Obx(() {
      final isExpanded = controller.isExpanded(category.id);

      return Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: EdgeInsets.only(bottom: 10, left: level * 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isExpanded
                    ? AppColors.primaryColor.withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasChildren ? Icons.folder : Icons.category,
                  color: AppColors.primaryColor,
                ),
              ),
              title: Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: hasChildren
                  ? Text(
                      '${category.children.length} items',
                      style: TextStyle(color: Colors.grey.shade600),
                    )
                  : null,
              trailing: hasChildren
                  ? AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(Icons.keyboard_arrow_down),
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (hasChildren) {
                  controller.toggleExpand(category.id);
                } else {
                  Get.toNamed(
                    '/products',
                    arguments: {
                      'categoryId': category.id,
                      'categoryName': category.name,
                    },
                  );
                }
              },
            ),
          ),

          /// Children Animation
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: category.children
                  .map((e) => CategoryTile(category: e, level: level + 1))
                  .toList(),
            ),
            secondChild: const SizedBox(),
          ),
        ],
      );
    });
  }
}
