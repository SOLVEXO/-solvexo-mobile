import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategorySearchBar extends StatelessWidget {
  final CategoryController controller;

  const CategorySearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: AppDimen.bottomPadding,
      ),
      child: CustomTextField(
        onChanged: controller.searchCategories,
        hintText: 'Search categories...',
        isborder: true,
        borderRadius: BorderRadius.circular(14),
        prefixIcon: SvgIcon(
          assetName: AppIcons.searchIcon,
          size: 20,
          color: AppColors.lightGrey,
        ),
        // isborder: true,
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? SvgIcon(
                  assetName: AppIcons.cross,
                  onTap: () => controller.searchCategories(''),
                  size: 15,
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
