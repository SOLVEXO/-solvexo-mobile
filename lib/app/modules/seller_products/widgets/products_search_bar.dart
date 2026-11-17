import 'package:book_store_app/app/components/app_search_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsSearchBar extends StatelessWidget {
  ProductsSearchBar({super.key});
  final SellerProductsController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(BaseSpacing.md),
      child: Obx(
        () => AppSearchField(
          controller: controller.searchController,
          onChanged: controller.onSearch,
          staticHint: 'Search products...',
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.searchController.clear();
                    controller.clearSearch();
                  },
                  child: SvgIcon(
                    assetName: AppIcons.cross,
                    color: AppColors.textPrimary,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
