import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsSearchBar extends StatelessWidget {
  ProductsSearchBar({super.key});
  final SellerProductsController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      child: CustomTextField(
        controller: textController,
        onChanged: controller.onSearch,
        hintText: 'Search products...',
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgIcon(
            assetName: AppIcons.searchIcon,
            size: 22,
            color: AppColors.gray600,
          ),
        ),
        isborder: true,
        ispadding: true,
        suffixIcon: Obx(() {
          if (controller.searchQuery.value.isEmpty) {
            return const SizedBox(width: 12);
          }
          return GestureDetector(
            onTap: () {
              textController.clear();
              controller.clearSearch();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.lightGrey5,
              ),
            ),
          );
        }),
      ),
    );
  }
}
