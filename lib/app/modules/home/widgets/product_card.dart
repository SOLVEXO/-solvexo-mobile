import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final int index;
  final ProductModel product;

  ProductCard({super.key, required this.product, required this.index});

  final homeController = Get.find<HomeController>();

  // Was `Get.put(ProductController())` as a field initializer — since a
  // grid renders many `ProductCard`s, this replaced the app-wide
  // `ProductController` singleton (which also holds category/pagination
  // filter state) once per card, every rebuild. `Get.find` reuses the one
  // instance the relevant binding already created.
  ProductController get productController {
    if (!Get.isRegistered<ProductController>()) Get.put(ProductController());
    return Get.find<ProductController>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => productController.openProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image — exactly 50% of card height ───────────────────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(BaseRadius.lg)),
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
                      top: BaseSpacing.xs,
                      right: BaseSpacing.xs,
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
                              boxShadow: BaseShadows.forLevel(BaseElevation.level1),
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
                padding: EdgeInsets.fromLTRB(BaseSpacing.sm - 1, BaseSpacing.sm - 2, BaseSpacing.sm - 1, BaseSpacing.sm - 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name + seller/rating grouped at the top
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: BaseTypography.labelSmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: BaseSpacing.xxs),
                        _SellerRatingRow(product: product),
                      ],
                    ),

                    // Price pinned to bottom of text zone
                    Text(
                      product.hasPriceRange
                          ? '\$${product.price.toStringAsFixed(0)} – \$${product.maxPrice.toStringAsFixed(0)}'
                          : '\$${product.price.toStringAsFixed(0)}',
                      style: BaseTypography.titleSmall(color: AppColors.black).copyWith(fontWeight: FontWeight.w800),
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
          child: Text(
            'by Seller · ',
            style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w400, fontSize: 10.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SvgIcon(
          assetName: AppIcons.fillStar,
          size: 11,
          color: const Color(0xFFFACC15),
        ),
        SizedBox(width: BaseSpacing.xxs / 2),
        Text(
          rating,
          style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w400, fontSize: 10.5),
        ),
      ],
    );
  }
}
