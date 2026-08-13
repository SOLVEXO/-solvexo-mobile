import 'package:book_store_app/app/components/app_search_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategorySearchBar extends StatelessWidget {
  final CategoryController controller;

  const CategorySearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSpacing.md,
        vertical: BaseSpacing.xs,
      ),
      child: Obx(
        () => AppSearchField(
          controller: controller.searchController,
          onChanged: controller.searchCategories,
          staticHint: 'Search categories...',
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? SvgIcon(
                  assetName: AppIcons.cross,
                  onTap: () {
                    controller.searchController.clear();
                    controller.searchCategories('');
                  },
                  size: 15,
                  color: AppColors.textPrimary,
                )
              : null,
        ),
      ),
    );
  }
}
