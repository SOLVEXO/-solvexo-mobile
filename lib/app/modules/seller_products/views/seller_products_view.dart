import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller/widgets/seller_app_bar.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_card.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_filter_bar.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/products_empty_state.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/products_search_bar.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/products_shimmer.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerProductsView extends StatelessWidget {
  SellerProductsView({super.key});

  final SellerProductsController controller = Get.put(
    SellerProductsController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.addSellerProduct),
        backgroundColor: AppColors.primaryColor,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const CustomText(
          text: 'Add Product',
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
      body: Column(
        children: [
          SellerAppBar(title: 'Products'),
          ProductsSearchBar(),
          ProductFilterBar(controller: controller),
          Expanded(
            child: CustomRefreshWrapper(
              onRefresh: controller.refreshData,
              child: Obx(() {
                if (controller.isLoading.value) return const ProductsShimmer();

                final products = controller.filteredProducts;
                final isSearch = controller.searchQuery.value.isNotEmpty;

                if (products.isEmpty) {
                  return ProductsEmptyState(isSearch: isSearch);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimen.allPadding),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => ProductCard(
                    product: products[i],
                    onEdit: () => Get.toNamed(
                      Routes.editSellerProduct,
                      arguments: products[i],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
