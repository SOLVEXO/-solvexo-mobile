import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/shimmer/trip_shimmer.dart';
import 'package:book_store_app/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:book_store_app/app/modules/wishlist/model/wishlist_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseViewScreen(
      showCustomAppBar: true,
      actions: [
        controller.wishlistItems.isNotEmpty
            ? CustomIconButton(
                assetName: AppIcons.deleteIcon,
                size: 24,
                isPadding: true,
                onPressed: () => controller.showDeleteConfirmation(),
              )
            : SizedBox(),
      ],
      backgroundColor: AppColors.background,
      screenName: 'Wishlist',
      child: CustomRefreshWrapper(
        onRefresh: () => controller.refresh(),
        child: Obx(() {
          // ── Loading ──────────────────────────────────────────────────
          if (controller.isLoading.value) {
            return TripShimmer(itemCount: 6);
          }

          // ── Empty ────────────────────────────────────────────────────
          if (controller.isEmpty) {
            return _EmptyWishlist();
          }

          // ── List ─────────────────────────────────────────────────────
          return Column(
            spacing: 10,
            children: [
              // item count header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'My Wishlist',
                    fontSize: AppFontSize.regular,
                    fontWeight: FontWeight.w600,
                  ),
                  Obx(
                    () => CustomText(
                      text: '${controller.count} items',
                      fontSize: AppFontSize.small,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),

              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  itemCount: controller.wishlistItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    return _WishlistCard(
                      item: controller.wishlistItems[i],
                      controller: controller,
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Wishlist Card ─────────────────────────────────────────────────────────

class _WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final WishlistController controller;

  const _WishlistCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final variant =
        item.selectedVariant ??
        (item.variants.isNotEmpty ? item.variants.first : null);
    final inStock = (variant?.stock ?? 0) > 0;

    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.productDetailsView,
        arguments: {'productId': product.id},
      ),
      child: Container(
        padding: EdgeInsets.all(AppDimen.allPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          spacing: AppDimen.allPadding,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image ──────────────────────────────────────
            ClipRRect(
              child: CommonImageView(
                url: item.displayImage,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),

            // ── Info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  CustomText(
                    text: product.name,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  // Variant badges
                  if (variant != null)
                    Row(
                      children: [
                        if (variant.color != null && variant.color!.isNotEmpty)
                          _Badge(label: variant.color!),
                        if (variant.color != null && variant.size != null)
                          const SizedBox(width: 6),
                        if (variant.size != null && variant.size!.isNotEmpty)
                          _Badge(label: variant.size!),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Price + stock
                  Row(
                    children: [
                      CustomText(
                        text: '\$${item.price.toStringAsFixed(2)}',
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryColor,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: inStock
                              ? AppColors.seaGreen.withOpacity(0.10)
                              : AppColors.red.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomText(
                          text: inStock ? 'In stock' : 'Out of stock',
                          fontSize: AppFontSize.small2,
                          fontWeight: FontWeight.w600,
                          color: inStock ? AppColors.darkGreen : AppColors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),

            // ── Remove (heart) button ──────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: GestureDetector(
                onTap: () {
                  final variantId =
                      item.wishlistEntry?.productVariantId ??
                      (item.variants.isNotEmpty ? item.variants.first.id : '');
                  controller.removeFromWishlist(
                    productVariantId: variantId,
                    wishlistId: item.wishlistId,
                  );
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: AppColors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Variant Badge ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: CustomText(
        text: label,
        fontSize: AppFontSize.verySmall,
        color: AppColors.primaryColor,
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 42,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 20),
            const CustomText(
              text: 'Your wishlist is empty',
              fontSize: AppFontSize.large,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            CustomText(
              text: 'Save items you love and come back to them anytime.',
              fontSize: AppFontSize.small2,
              color: AppColors.gray600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const CustomText(
                  text: 'Explore Products',
                  fontSize: AppFontSize.regular,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
