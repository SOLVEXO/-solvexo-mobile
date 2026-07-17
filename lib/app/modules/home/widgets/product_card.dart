import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/components/wishlist_heart_button.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/notched_image_box.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final int index;
  final ProductModel product;

  ProductCard({super.key, required this.product, required this.index});

  final homeController = Get.find<HomeController>();

  ProductController get productController {
    if (!Get.isRegistered<ProductController>()) Get.put(ProductController());
    return Get.find<ProductController>();
  }

  // Half the add-to-cart button sits below the image box, overlapping into
  // the text zone — this is how much bottom room the image box must give up.
  static const double _cartButtonSize = 30;
  static const double _cartButtonOverlap = _cartButtonSize / 2;

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
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image box — peach background + terracotta notched border ──────
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: _cartButtonOverlap),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: NotchedImageBox(
                        heartGap: BaseSpacing.xs,
                        heartSize: 28,
                        radius: BaseRadius.lg,
                        // height/width: double.infinity forces CommonImageView
                        // to fill the box regardless of the image's own
                        // aspect ratio — without this it sizes to the image's
                        // natural dimensions and leaves blank space around it.
                        child: product.images.isNotEmpty
                            ? CommonImageView(
                                url: product.images.first,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              )
                            : const Icon(
                                Icons.image_outlined,
                                color: AppColors.lightGrey7,
                                size: 40,
                              ),
                      ),
                    ),

                    // Wishlist heart — sitting inside the notch, top right
                    Positioned(
                      top: 0,
                      right: 0,
                      child: WishlistHeartButton(
                        productId: product.id,
                        variantId: product.variants.isNotEmpty
                            ? product.variants.first.id
                            : '',
                      ),
                    ),

                    // Add to cart — overlaps the bottom-right corner of the
                    // image box, same as the reference design's bag button.
                    Positioned(
                      bottom: -_cartButtonOverlap,
                      right: BaseSpacing.xs,
                      child: GestureDetector(
                        onTap: () => homeController.quickAddToCart(product),
                        child: Container(
                          width: _cartButtonSize,
                          height: _cartButtonSize,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: BaseShadows.forLevel(
                              BaseElevation.level1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: SvgIcon(
                            assetName: AppIcons.shoppingBag,
                            size: 14,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Text — sized to content, no forced empty space ─────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                BaseSpacing.xs,
                BaseSpacing.xs,
                BaseSpacing.xs,
                BaseSpacing.xxs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: product.name,
                    color: AppColors.black2,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: BaseSpacing.xxs),
                  _SellerRatingRow(product: product),
                  SizedBox(height: BaseSpacing.xxs),
                  product.hasDiscount
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            CustomText(
                              text:
                                  '\$${product.compareAtPrice!.toStringAsFixed(0)}',
                              color: AppColors.gray600,
                              fontSize: AppFontSize.tiny,
                              fontWeight: FontWeight.w500,
                              textDecoration: TextDecoration.lineThrough,
                            ),
                            SizedBox(width: BaseSpacing.xxs),
                            CustomText(
                              text: '\$${product.price.toStringAsFixed(0)}',
                              color: AppColors.primaryColor,
                              fontSize: AppFontSize.verySmall,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        )
                      : CustomText(
                          text: product.hasPriceRange
                              ? '\$${product.price.toStringAsFixed(0)} – \$${product.maxPrice.toStringAsFixed(0)}'
                              : '\$${product.price.toStringAsFixed(0)}',
                          color: AppColors.primaryColor,
                          fontSize: AppFontSize.verySmall,
                          fontWeight: FontWeight.w800,
                        ),
                ],
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
            color: AppColors.gray600,
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
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
        CustomText(
          text: rating,
          color: AppColors.gray600,
          fontSize: 10.5,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}
