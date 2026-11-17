import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class ProductsEmptyState extends StatelessWidget {
  final bool isSearch;

  const ProductsEmptyState({super.key, this.isSearch = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimen.allPadding),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.lightGrey,
            ),
          ),
          const SizedBox(height: 16),
          CustomText(
            text: isSearch ? 'No products match your search' : 'No products found',
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.w600,
            color: AppColors.black2,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: isSearch
                ? 'Try a different keyword'
                : 'Add your first product to get started',
            fontSize: AppFontSize.verySmall,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
