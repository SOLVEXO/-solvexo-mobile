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
            // ── Cream image area (flush to card edges, rounded top) ──
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.05,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppColors.languageBg,
                      child: product.images.isNotEmpty
                          ? CommonImageView(
                              url: product.images.first,
                              fit: BoxFit.contain,
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: AppColors.lightGrey7,
                                size: 40,
                              ),
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
                            width: 30,
                            height: 30,
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
                            child: Center(
                              child: SvgIcon(
                                assetName:
                                    homeController.isFavourite(product.id)
                                        ? AppIcons.heartFill
                                        : AppIcons.heartIcon,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Text content ─────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    CustomText(
                      text: product.name,
                      fontSize: AppFontSize.extraSmall,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // "by Seller · ⭐ rating" row
                    _SellerRatingRow(product: product),

                    const Spacer(),

                    // Price
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
