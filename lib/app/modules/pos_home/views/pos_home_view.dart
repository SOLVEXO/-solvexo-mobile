import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/app/modules/pos/widgets/pos_app_bar.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosHomeView extends StatelessWidget {
  final controller = Get.put(PosHomeController());

  PosHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PosAppBar(),
          _buildSearchBar(),
          const Divider(height: 1, color: AppColors.lightGrey2),
          const SizedBox(height: 12),
          _buildCategoryChips(),
          const SizedBox(height: 12),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: 10,
      ),
      child: CustomTextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        hintText: 'Search or scan barcode...',
        fillColor: AppColors.textfldFillColor,
        isborder: true,

        // isborder: true,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          return Obx(() {
            final cat = controller.categories[i];
            final isSelected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.selectCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryColor : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomText(
                  text: cat,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.white : AppColors.iosGrey,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      final products = controller.filteredProducts;
      if (products.isEmpty) {
        return const Center(
          child: CustomText(
            text: 'No products found',
            fontSize: 15,
            color: AppColors.iosGrey,
          ),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.82,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => _productCard(products[i]),
      );
    });
  }

  Widget _productCard(PosProduct product) {
    return GestureDetector(
      onTap: product.inStock ? () {} : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(product.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: CustomText(
                text: product.name,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: product.inStock ? AppColors.black : AppColors.red,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              text: '\$${product.price.toStringAsFixed(0)}',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: product.inStock
                  ? AppColors.primaryColor
                  : AppColors.inactiveGrey,
            ),
          ],
        ),
      ),
    );
  }
}
