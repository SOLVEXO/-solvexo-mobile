import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/widgets/horizontal_product_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A titled horizontal rail of products — reused for a seller storefront's
/// four merchandising sections (Pinned / New Arrivals / Best Sellers /
/// Trending). Strict no-fake-data: renders nothing at all when [products]
/// is empty, never an empty-state placeholder.
class ProductHorizontalSection extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const ProductHorizontalSection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: BaseSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
            child: CustomText(
              text: title,
              fontFamily: AppTextStyles.headingFontFamily,
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.w700,
              color: AppColors.black2,
            ),
          ),
          SizedBox(height: BaseSpacing.sm),
          SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final product = products[i];
                return Padding(
                  padding: EdgeInsets.only(right: BaseSpacing.sm),
                  child: SizedBox(
                    width: 280,
                    child: HorizontalProductCard(
                      prod: product,
                      onTap: () => Get.toNamed(
                        Routes.productDetailsView,
                        arguments: {'productId': product.id},
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
