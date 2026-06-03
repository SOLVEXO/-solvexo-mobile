import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/pos_products/controllers/pos_products_controller.dart';
import 'package:book_store_app/app/modules/pos_products/widgets/pos_product_tile.dart';
import 'package:book_store_app/app/modules/pos_products/widgets/pos_products_empty.dart';
import 'package:book_store_app/app/modules/pos_products/widgets/pos_products_shimmer.dart';
import 'package:book_store_app/app/modules/pos/widgets/pos_app_bar.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosProductsView extends StatelessWidget {
  PosProductsView({super.key});

  final PosProductsController controller = Get.put(PosProductsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const PosAppBar(title: 'Products', subtitle: 'EduDeen POS'),
          _SearchBar(controller: controller),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const PosProductsShimmer();
              }
              final products = controller.filteredProducts;
              if (products.isEmpty) return const PosProductsEmpty();
              return CustomRefreshWrapper(
                onRefresh: controller.refreshData,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimen.allPadding),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => PosProductTile(product: products[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final PosProductsController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: 10,
      ),
      child: CustomTextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        hintText: 'Search products or SKU...',
        isborder: true,
        fillColor: AppColors.textfldFillColor,
      ),
    );
  }
}
