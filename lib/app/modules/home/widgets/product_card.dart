import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final int index;
  final ProductModel product;

  ProductCard({super.key, required this.product, required this.index});

  final homeController = Get.find<HomeController>();
  final productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => productController.openProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image — exactly 50% of card height ───────────────────
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.images.isNotEmpty
                        ? CommonImageView(
                            url: product.images.first,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.languageBg,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.lightGrey7,
                              size: 40,
                            ),
                          ),
                    // Wishlist heart — top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Obx(
                        () => GestureDetector(
                          onTap: () => homeController.addorRemoveWishList(
                            product.id,
                            product.variants.isNotEmpty
                                ? product.variants.first.id
                                : '',
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.88),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: SvgIcon(
                              assetName: homeController.isFavourite(product.id)
                                  ? AppIcons.heartFill
                                  : AppIcons.heartIcon,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Text — exactly 50% of card height ────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name + seller/rating grouped at the top
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: product.name,
                          fontSize: AppFontSize.extraSmall,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        _SellerRatingRow(product: product),
                      ],
                    ),

                    // Price pinned to bottom of text zone
                    CustomText(
                      text: product.hasPriceRange
                          ? '\$${product.price.toStringAsFixed(0)} – \$${product.maxPrice.toStringAsFixed(0)}'
                          : '\$${product.price.toStringAsFixed(0)}',
                      fontSize: AppFontSize.medium,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── "by Seller · ⭐ rating" subtitle ────────────────────────────────────────

class _SellerRatingRow extends StatelessWidget {
  const _SellerRatingRow({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final rating = product.averageRating.toStringAsFixed(1);
    return Row(
      children: [
        Flexible(
          child: CustomText(
            text: 'by Seller · ',
            fontSize: AppFontSize.tiny,
            color: AppColors.gray600,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SvgIcon(
          assetName: AppIcons.fillStar,
          size: 11,
          color: const Color(0xFFFACC15),
        ),
        const SizedBox(width: 2),
        CustomText(
          text: rating,
          fontSize: AppFontSize.tiny,
          color: AppColors.gray600,
        ),
      ],
    );
  }
}
