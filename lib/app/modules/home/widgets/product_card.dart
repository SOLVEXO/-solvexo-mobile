import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/pricing_section.dart';
import 'package:book_store_app/app/modules/home/widgets/product_image_with_favorite_button.dart';
import 'package:book_store_app/app/modules/home/widgets/ratting_row.dart';
import 'package:book_store_app/app/modules/home/widgets/seller_name_row.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  ProductCard({super.key, required this.product});

  final controller = Get.find<HomeController>();
  final categoryController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    double radius = AppDimen.borderRadius;

    return GestureDetector(
      onTap: () => categoryController.openProductDetails(product),
      child: Container(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          spacing: 2,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Favorite Button and Discount Badge
            ProductImageWithFavoriteButton(product: product),

            const SizedBox(height: 5),

            // Product Name
            CustomText(
              text: product.name,
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Brand or Category
            if (product.brand != null || product.category != null)
              CustomText(
                text: product.brand ?? product.category?.name ?? '',
                fontSize: AppFontSize.small2,
                color: Colors.grey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            // Rating
            RattingRow(product: product),
            // Price Section
            PricingSection(product: product),
            // Featured Badge (Optional)
            if (product.isFeatured)
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomText(
                  text: "Featured",
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),

            // CustomText(
            //   text: "Stock (${product.stock.toString()})",
            //   fontSize: AppFontSize.small2,
            // ),
            const SizedBox(height: 5),
            SellerNameRow(name: "Seller Name"),
          ],
        ),
      ),
    );
  }
}
