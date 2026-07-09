import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_rating_bar.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/models/rating/review_model.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/app/modules/product_details/widgets/product_detail_shimmer.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductDetailsView extends StatelessWidget {
  ProductDetailsView({super.key});

  // ── Controllers ────────────────────────────────────────────────────────
  // ProductDetailController is intentionally re-put on every navigation
  // here — each product page needs fresh state for the new productId
  // (matches ProductDetailBinding's own lazyPut for the routed case).
  final controller = Get.put(ProductDetailController());

  // These two are app-wide shared controllers, unlike the one above — was
  // `Get.put(...)` here too, which replaced the *live* ProfileController /
  // BottomNavController singleton every single time a product page opened,
  // discarding whatever state (logged-in user, selected tab) they held.
  ProfileController get profileController {
    if (!Get.isRegistered<ProfileController>()) Get.put(ProfileController());
    return Get.find<ProfileController>();
  }

  BottomNavController get bottombarcontroller {
    if (!Get.isRegistered<BottomNavController>())
      Get.put(BottomNavController());
    return Get.find<BottomNavController>();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Bottom bar only shown once product is loaded and user is logged in
      bottomNavigationBar: profileController.user.isNull
          ? null
          : Obx(
              () => controller.isLoading.value
                  ? const SizedBox.shrink()
                  : _bottomBar(size, context),
            ),
      // `bottom: false` when a bottom bar is present — the Scaffold already
      // excludes that area from `body`, so a second bottom inset here would
      // just add a redundant gap above it.
      body: SafeArea(
        bottom: profileController.user.isNull,
        child: Obx(() {
          // ── Loading state ───────────────────────────────────────────────
          if (controller.isLoading.value) {
            return ProductDetailShimmer();
          }

          final product = controller.product.value;

          // ── Error / not found state ─────────────────────────────────────
          if (product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: AppColors.gray600,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  CustomText(
                    text: 'Product not found',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            );
          }

          // ── Product loaded ──────────────────────────────────────────────
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image carousel + floating back/share/heart ───────
                _HeroGallery(controller: controller),

                Container(
                  color: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: BaseSpacing.xl,
                    vertical: BaseSpacing.sm,
                  ),
                  width: double.infinity,
                  child: Column(
                    spacing: BaseSpacing.xs,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Seller / store row ──────────────────────────────
                      if (product.sellerId.isNotEmpty)
                        _SellerStoreCard(product: product),

                      // ── Name ─────────────────────────────────────────────
                      CustomText(
                        text: product.name,
                        color: AppColors.black,
                        fontSize: AppFontSize.regular,
                        fontWeight: FontWeight.w600,
                      ),

                      // ── Price + Stock pill ──────────────────────────────
                      Obx(
                        () => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                              text: '\$${controller.displayPrice.toStringAsFixed(2)}',
                              color: AppColors.primaryColor,
                              fontSize: AppFontSize.regular,
                              fontWeight: FontWeight.w800,
                            ),
                            SizedBox(width: BaseSpacing.sm),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: BaseSpacing.xs + 2,
                                vertical: BaseSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (controller.inStock
                                            ? AppColors.green2
                                            : AppColors.red)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  BaseRadius.pill,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    controller.inStock
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    size: 13,
                                    color: controller.inStock
                                        ? AppColors.green2
                                        : AppColors.red,
                                  ),
                                  SizedBox(width: BaseSpacing.xxs / 2),
                                  CustomText(
                                    text: controller.inStock
                                        ? 'In stock (${controller.displayStock})'
                                        : 'Out of stock',
                                    color: controller.inStock
                                        ? AppColors.green2
                                        : AppColors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      // ── Variants ────────────────────────────────────────
                      Obx(() {
                        final variants = controller.variants;
                        if (variants.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Colors
                            if (product.availableColors.isNotEmpty) ...[
                              titleText('Color'),
                              SizedBox(height: BaseSpacing.xs),
                              Wrap(
                                spacing: BaseSpacing.xs,
                                runSpacing: BaseSpacing.xs,
                                children: variants
                                    .where(
                                      (v) =>
                                          v.color != null &&
                                          v.color!.isNotEmpty,
                                    )
                                    .map((v) {
                                      final isSelected =
                                          controller
                                              .selectedVariant
                                              .value
                                              ?.id ==
                                          v.id;
                                      return Semantics(
                                        button: true,
                                        selected: isSelected,
                                        label: 'Color ${v.color}',
                                        child: GestureDetector(
                                          onTap: () =>
                                              controller.selectVariant(v),
                                          child: AnimatedContainer(
                                            duration: BaseMotion.normal,
                                            constraints: const BoxConstraints(
                                              minHeight: 40,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: BaseSpacing.xs + 2,
                                              vertical: BaseSpacing.xxs + 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primaryColor
                                                  : AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    BaseRadius.sm,
                                                  ),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryColor
                                                    : AppColors.lightGrey,
                                                width: 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: CustomText(
                                              text: v.color!,
                                              color: isSelected
                                                  ? AppColors.white
                                                  : AppColors.textPrimary,
                                              fontSize: AppFontSize.tiny,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ],

                            // Sizes
                            if (product.availableSizes.isNotEmpty) ...[
                              SizedBox(height: BaseSpacing.sm),
                              titleText('Size'),
                              SizedBox(height: BaseSpacing.xs),
                              Wrap(
                                spacing: BaseSpacing.xs,
                                runSpacing: BaseSpacing.xs,
                                children: variants
                                    .where(
                                      (v) =>
                                          v.size != null && v.size!.isNotEmpty,
                                    )
                                    .map((v) {
                                      final isSelected =
                                          controller
                                              .selectedVariant
                                              .value
                                              ?.id ==
                                          v.id;
                                      final outOfStock = !v.isInStock;
                                      return Semantics(
                                        button: true,
                                        selected: isSelected,
                                        enabled: !outOfStock,
                                        label: outOfStock
                                            ? 'Size ${v.size}, out of stock'
                                            : 'Size ${v.size}',
                                        child: GestureDetector(
                                          onTap: outOfStock
                                              ? null
                                              : () =>
                                                    controller.selectVariant(v),
                                          child: AnimatedContainer(
                                            duration: BaseMotion.normal,
                                            constraints: const BoxConstraints(
                                              minHeight: 40,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: BaseSpacing.xs + 2,
                                              vertical: BaseSpacing.xxs + 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: outOfStock
                                                  ? AppColors.lightGrey
                                                        .withOpacity(0.3)
                                                  : isSelected
                                                  ? AppColors.primaryColor
                                                  : AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    BaseRadius.sm,
                                                  ),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primaryColor
                                                    : AppColors.lightGrey,
                                                width: 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: CustomText(
                                              text: v.size!,
                                              color: outOfStock
                                                  ? AppColors.gray600
                                                  : isSelected
                                                  ? AppColors.white
                                                  : AppColors.textPrimary,
                                              fontSize: AppFontSize.tiny,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ],

                            // Selected variant SKU + stock badge
                            Obx(() {
                              final v = controller.selectedVariant.value;
                              if (v == null) return const SizedBox.shrink();
                              return Padding(
                                padding: EdgeInsets.only(top: BaseSpacing.sm),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: BaseSpacing.xs + 2,
                                        vertical: BaseSpacing.xxs + 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(
                                          BaseRadius.pill,
                                        ),
                                      ),
                                      child: CustomText(
                                        text: 'SKU: ${v.sku}',
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    // Loading indicator when fetching variant
                                    if (controller.isLoadingVariant.value)
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryColor,
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: BaseSpacing.xs + 2,
                                          vertical: BaseSpacing.xxs + 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: v.isInStock
                                              ? AppColors.green2.withOpacity(
                                                  0.10,
                                                )
                                              : AppColors.red.withOpacity(0.10),
                                          borderRadius: BorderRadius.circular(
                                            BaseRadius.pill,
                                          ),
                                        ),
                                        child: CustomText(
                                          text: v.isUnlimited
                                              ? '∞ Unlimited'
                                              : v.isInStock
                                              ? '${v.stock} in stock'
                                              : 'Out of stock',
                                          color: v.isInStock
                                              ? AppColors.green2
                                              : AppColors.red,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      }),

                      const Divider(),

                      titleText('Description'),
                      CustomText(
                        text: product.description,
                        color: AppColors.black,
                        fontSize: AppFontSize.tiny,
                      ),

                      // ── Rating + sold row ───────────────────────────────
                      Row(
                        spacing: BaseSpacing.xxs + 1,
                        children: [
                          SvgIcon(assetName: AppIcons.fillStar, size: 16),
                          CustomText(
                            text: product.averageRating.toStringAsFixed(1),
                            color: AppColors.black,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            text: '(${controller.reviewStats.value.totalReviews})',
                            color: AppColors.gray600,
                            fontSize: AppFontSize.tiny,
                          ),
                          const VerticalDivider(
                            color: AppColors.black,
                            width: 1,
                            thickness: 2,
                          ),
                          CustomText(
                            text: '${product.purchaseCount} Sold',
                            color: AppColors.black,
                            fontSize: AppFontSize.tiny,
                          ),
                        ],
                      ),

                      const Divider(),

                      // ── Reviews expansion tile ──────────────────────────
                      _expandTile('Reviews', false.obs, _buildReviewsContent()),

                      const Divider(),

                      titleText('Related Products'),
                      RecommendedProductList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget titleText(String text, {Color color = AppColors.black}) {
    return CustomText(
      text: text,
      color: color,
      fontSize: AppFontSize.small2,
      fontWeight: FontWeight.w800,
    );
  }

  Widget _buildReviewsContent() {
    if (controller.isLoadingReviews.value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      );
    }

    if (controller.reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
        child: CustomText(
          text: 'No reviews yet. Be the first to review this product!',
          textAlign: TextAlign.center,
          color: AppColors.gray600,
          fontSize: AppFontSize.tiny,
        ),
      );
    }

    return Column(children: controller.reviews.map(_reviewTile).toList());
  }

  Widget _reviewTile(ReviewModel review) {
    return Padding(
      padding: EdgeInsets.only(bottom: BaseSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: review.customerName.isEmpty
                        ? 'Anonymous'
                        : review.customerName,
                    color: AppColors.black,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (review.isVerifiedPurchase)
                  CustomText(
                    text: 'Verified Purchase',
                    color: AppColors.green2,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w600,
                  ),
              ],
            ),
            subtitle: review.rating != null
                ? Padding(
                    padding: EdgeInsets.only(top: BaseSpacing.xxs),
                    child: CustomRatingBar(
                      rating: review.rating!,
                      itemSize: 15,
                      ignoreGestures: true,
                    ),
                  )
                : null,
          ),
          if (review.commentText.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: BaseSpacing.md,
                right: BaseSpacing.md,
                bottom: BaseSpacing.xxs,
              ),
              child: CustomText(
                text: review.commentText,
                color: AppColors.gray600,
                fontSize: AppFontSize.tiny,
              ),
            ),
          if (review.sellerReply != null)
            Container(
              margin: EdgeInsets.only(
                left: BaseSpacing.xxl,
                right: BaseSpacing.md,
                bottom: BaseSpacing.sm,
              ),
              padding: EdgeInsets.all(BaseSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(BaseRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Seller response',
                    color: AppColors.primaryColor,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: BaseSpacing.xxs / 2),
                  CustomText(
                    text: review.sellerReply!.text,
                    color: AppColors.black2,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _expandTile(String title, RxBool toggle, Widget content) {
    return Obx(
      () => ExpansionTile(
        collapsedShape: const Border(top: BorderSide.none),
        shape: const Border(top: BorderSide.none),
        title: titleText(title),
        initiallyExpanded: toggle.value,
        onExpansionChanged: (v) => toggle.value = v,
        children: [
          Padding(padding: EdgeInsets.all(BaseSpacing.sm), child: content),
        ],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────

  Widget _bottomBar(Size size, BuildContext context) {
    if (profileController.user.value.isNull) {
      return Container(
        color: AppColors.white,
        padding: EdgeInsets.only(
          left: BaseSpacing.xxl - 2,
          right: BaseSpacing.xxl - 2,
          bottom: BaseSpacing.md + 4,
          top: BaseSpacing.xxs + 1,
        ),
        child: PrimaryButton(
          label: 'Login',
          onPressed: () => Get.toNamed(Routes.authTabView),
        ),
      );
    }

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        left: BaseSpacing.xxl - 2,
        right: BaseSpacing.xxl - 2,
        bottom: BaseSpacing.md + 4,
        top: BaseSpacing.xxs + 1,
      ),
      child: Row(
        spacing: BaseSpacing.sm,
        children: [
          // ── Qty stepper ───────────────────────────────────────────
          Obx(
            () => Container(
              width: size.width / 2.5,
              padding: EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textPrimary, width: 0.4),
                borderRadius: BorderRadius.circular(BaseRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: controller.decreaseQty,
                    icon: Icon(Icons.remove, color: AppColors.primaryColor),
                  ),
                  CustomText(
                    text: controller.productQty.value.toString(),
                    color: AppColors.black,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w600,
                  ),
                  IconButton(
                    onPressed: controller.increaseQty,
                    icon: Icon(Icons.add, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
          ),

          // ── Add to cart ───────────────────────────────────────────
          Expanded(
            child: Obx(
              () => PrimaryButton(
                label: controller.isAddtoCartLoading.value
                    ? "Adding..."
                    : 'Add to cart',
                isLoading: controller.isAddtoCartLoading.value,
                onPressed: controller.isAddtoCartLoading.value
                    ? null
                    : () => controller.addToCart(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero image carousel with floating back/share/heart buttons ─────────────

// Stateless — the `PageController` + current-page index live on
// `ProductDetailController` (disposed in its `onClose`) so this widget
// never needs its own `State`, matching the rest of this screen.
class _HeroGallery extends StatelessWidget {
  final ProductDetailController controller;
  const _HeroGallery({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = controller.displayImages;
      return SizedBox(
        height: Get.height / 3.1,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: AppColors.background,
              child: images.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.lightGrey7,
                        size: 48,
                      ),
                    )
                  : PageView.builder(
                      controller: controller.imagePageController,
                      onPageChanged: (i) => controller.imagePage.value = i,
                      itemCount: images.length,
                      itemBuilder: (_, i) =>
                          CommonImageView(url: images[i], fit: BoxFit.contain),
                    ),
            ),

            // Back button — the screen's own `SafeArea` already keeps this
            // clear of the status bar, so no nested one is needed here.
            Positioned(
              top: BaseSpacing.sm,
              left: BaseSpacing.md,
              child: _CircleIconButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => Get.back(),
              ),
            ),

            // Share + wishlist
            Positioned(
              top: BaseSpacing.sm,
              right: BaseSpacing.md,
              child: Row(
                children: [
                  _CircleIconButton(assetName: AppIcons.shareIcon),
                  SizedBox(width: BaseSpacing.xs),
                  _CircleIconButton(assetName: AppIcons.heartIcon),
                ],
              ),
            ),

            // Dot indicator
            if (images.length > 1)
              Positioned(
                bottom: BaseSpacing.sm,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(
                    () => SmoothIndicator(
                      offset: controller.imagePage.value.toDouble(),
                      count: images.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        spacing: 6,
                        activeDotColor: AppColors.primaryColor,
                        dotColor: AppColors.white,
                      ),
                      size: Size(Get.width * 0.18, 20),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData? icon;
  final String? assetName;
  final VoidCallback? onTap;
  const _CircleIconButton({this.icon, this.assetName, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 22, color: AppColors.black2)
            : SvgIcon(assetName: assetName!, size: 16),
      ),
    );
  }
}

class _SellerStoreCard extends StatelessWidget {
  final ProductModel product;
  const _SellerStoreCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final String? slug = product.storeSlug;
    final String? name = product.storeName;
    final String? logo = product.storeLogo;
    final String? sellerName = product.sellerName;
    final String displayName = (name != null && name.isNotEmpty)
        ? name
        : (sellerName != null && sellerName.isNotEmpty)
        ? sellerName
        : 'Store';
    final String initials = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : 'S';
    final bool canVisit = slug != null && slug.isNotEmpty;

    return Semantics(
      button: canVisit,
      label: canVisit
          ? 'Sold by $displayName, visit store'
          : 'Sold by $displayName',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(BaseRadius.pill),
            child: logo != null && logo.isNotEmpty
                ? CommonImageView(
                    url: logo,
                    height: 36,
                    width: 36,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 36,
                    width: 36,
                    color: AppColors.primaryColor.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: CustomText(
                      text: initials,
                      color: AppColors.primaryColor,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(width: BaseSpacing.xs + 2),
          Expanded(
            child: CustomText(
              text: displayName,
              color: AppColors.black2,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (canVisit)
            GestureDetector(
              onTap: () =>
                  Get.toNamed(Routes.sellerStorefront, arguments: slug),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSpacing.sm,
                  vertical: BaseSpacing.xxs + 1,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                  border: Border.all(color: AppColors.primaryColor, width: 1.2),
                ),
                child: CustomText(
                  text: 'Visit Store',
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
