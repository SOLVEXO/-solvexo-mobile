import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_rating_bar.dart';
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
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    if (!Get.isRegistered<BottomNavController>()) Get.put(BottomNavController());
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
      appBar: CustomAppBarTwo(
        actions: [
          SvgIcon(
            onTap: () => Get.toNamed(Routes.searchView),
            assetName: AppIcons.searchIcon,
            size: 22,
          ),
          Padding(
            padding: EdgeInsets.only(right: BaseSpacing.xl, left: BaseSpacing.xxs + 1),
            child: CartIconWithCount(),
          ),
        ],
      ),
      body: Obx(() {
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
                Text('Product not found', style: BaseTypography.bodyLarge(color: AppColors.gray600)),
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
              // ── Hero image (from selected variant or product) ─────────
              Center(
                child: Container(
                  height: Get.height / 4,
                  width: double.infinity,
                  color: AppColors.background,
                  child: Obx(
                    () => CommonImageView(
                      url: controller.displayImages.isNotEmpty
                          ? controller.displayImages.first
                          : '',
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              Container(
                color: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSpacing.xl,
                  vertical: BaseSpacing.xs,
                ),
                width: double.infinity,
                child: Column(
                  spacing: BaseSpacing.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name + actions ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: BaseTypography.titleLarge(color: AppColors.black),
                          ),
                        ),
                        const Spacer(),
                        CustomIconButton(
                          assetName: AppIcons.shareIcon,
                          isPadding: true,
                        ),
                        CustomIconButton(assetName: AppIcons.heartIcon),
                      ],
                    ),

                    // ── Price + Stock ───────────────────────────────────
                    Obx(
                      () => Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          titleText(
                            '\$ ${controller.displayPrice.toStringAsFixed(2)}',
                            color: AppColors.primaryColor,
                          ),
                          Text(
                            'Stock (${controller.displayStock})',
                            style: BaseTypography.labelSmall(
                              color: controller.inStock ? AppColors.green2 : AppColors.red,
                            ).copyWith(fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    // ── Seller / store card ─────────────────────────────
                    if (product.sellerId.isNotEmpty) _SellerStoreCard(product: product),

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
                                  .where((v) => v.color != null && v.color!.isNotEmpty)
                                  .map((v) {
                                    final isSelected = controller.selectedVariant.value?.id == v.id;
                                    return Semantics(
                                      button: true,
                                      selected: isSelected,
                                      label: 'Color ${v.color}',
                                      child: GestureDetector(
                                        onTap: () => controller.selectVariant(v),
                                        child: AnimatedContainer(
                                          duration: BaseMotion.normal,
                                          constraints: const BoxConstraints(minHeight: 40),
                                          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs + 1),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.primaryColor : AppColors.background,
                                            borderRadius: BorderRadius.circular(BaseRadius.sm),
                                            border: Border.all(
                                              color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
                                              width: 1.5,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            v.color!,
                                            style: BaseTypography.labelSmall(
                                              color: isSelected ? AppColors.white : AppColors.textPrimary,
                                            ).copyWith(fontWeight: FontWeight.w600),
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
                                  .where((v) => v.size != null && v.size!.isNotEmpty)
                                  .map((v) {
                                    final isSelected = controller.selectedVariant.value?.id == v.id;
                                    final outOfStock = !v.isInStock;
                                    return Semantics(
                                      button: true,
                                      selected: isSelected,
                                      enabled: !outOfStock,
                                      label: outOfStock ? 'Size ${v.size}, out of stock' : 'Size ${v.size}',
                                      child: GestureDetector(
                                        onTap: outOfStock ? null : () => controller.selectVariant(v),
                                        child: AnimatedContainer(
                                          duration: BaseMotion.normal,
                                          constraints: const BoxConstraints(minHeight: 40),
                                          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs + 1),
                                          decoration: BoxDecoration(
                                            color: outOfStock
                                                ? AppColors.lightGrey.withOpacity(0.3)
                                                : isSelected
                                                    ? AppColors.primaryColor
                                                    : AppColors.background,
                                            borderRadius: BorderRadius.circular(BaseRadius.sm),
                                            border: Border.all(
                                              color: isSelected ? AppColors.primaryColor : AppColors.lightGrey,
                                              width: 1.5,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            v.size!,
                                            style: BaseTypography.labelSmall(
                                              color: outOfStock
                                                  ? AppColors.gray600
                                                  : isSelected
                                                      ? AppColors.white
                                                      : AppColors.textPrimary,
                                            ).copyWith(fontWeight: FontWeight.w600),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs + 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(BaseRadius.pill),
                                    ),
                                    child: Text(
                                      'SKU: ${v.sku}',
                                      style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w600, fontSize: 11),
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
                                      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs + 1),
                                      decoration: BoxDecoration(
                                        color: v.isInStock
                                            ? AppColors.green2.withOpacity(0.10)
                                            : AppColors.red.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(BaseRadius.pill),
                                      ),
                                      child: Text(
                                        v.isUnlimited
                                            ? '∞ Unlimited'
                                            : v.isInStock
                                                ? '${v.stock} in stock'
                                                : 'Out of stock',
                                        style: BaseTypography.labelSmall(
                                          color: v.isInStock ? AppColors.green2 : AppColors.red,
                                        ).copyWith(fontWeight: FontWeight.w600, fontSize: 11),
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
                    Text(product.description, style: BaseTypography.bodySmall(color: AppColors.black)),

                    // ── Rating + sold row ───────────────────────────────
                    Row(
                      spacing: BaseSpacing.xxs + 1,
                      children: [
                        SvgIcon(assetName: AppIcons.fillStar, size: 16),
                        Text(
                          product.averageRating.toStringAsFixed(1),
                          style: BaseTypography.bodySmall(color: AppColors.black).copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '(${controller.reviewStats.value.totalReviews})',
                          style: BaseTypography.bodySmall(color: AppColors.gray600),
                        ),
                        const VerticalDivider(color: AppColors.black, width: 1, thickness: 2),
                        Text('${product.purchaseCount} Sold', style: BaseTypography.bodySmall(color: AppColors.black)),
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
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget titleText(String text, {Color color = AppColors.black}) {
    return Text(text, style: BaseTypography.titleMedium(color: color).copyWith(fontWeight: FontWeight.w800));
  }

  Widget _buildReviewsContent() {
    if (controller.isLoadingReviews.value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
          ),
        ),
      );
    }

    if (controller.reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: BaseSpacing.md),
        child: Text(
          'No reviews yet. Be the first to review this product!',
          textAlign: TextAlign.center,
          style: BaseTypography.bodySmall(color: AppColors.gray600),
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
                  child: Text(
                    review.customerName.isEmpty ? 'Anonymous' : review.customerName,
                    style: BaseTypography.bodySmall(color: AppColors.black).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (review.isVerifiedPurchase)
                  Text(
                    'Verified Purchase',
                    style: BaseTypography.labelSmall(color: AppColors.green2).copyWith(fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            subtitle: review.rating != null
                ? Padding(
                    padding: EdgeInsets.only(top: BaseSpacing.xxs),
                    child: CustomRatingBar(rating: review.rating!, itemSize: 15, ignoreGestures: true),
                  )
                : null,
          ),
          if (review.commentText.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: BaseSpacing.md, right: BaseSpacing.md, bottom: BaseSpacing.xxs),
              child: Text(review.commentText, style: BaseTypography.bodySmall(color: AppColors.gray600)),
            ),
          if (review.sellerReply != null)
            Container(
              margin: EdgeInsets.only(left: BaseSpacing.xxl, right: BaseSpacing.md, bottom: BaseSpacing.sm),
              padding: EdgeInsets.all(BaseSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(BaseRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seller response',
                    style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: BaseSpacing.xxs / 2),
                  Text(review.sellerReply!.text, style: BaseTypography.labelSmall(color: AppColors.black2).copyWith(fontWeight: FontWeight.w400)),
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
        children: [Padding(padding: EdgeInsets.all(BaseSpacing.sm), child: content)],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────

  Widget _bottomBar(Size size, BuildContext context) {
    if (profileController.user.value.isNull) {
      return Container(
        color: AppColors.white,
        padding: EdgeInsets.only(left: BaseSpacing.xxl - 2, right: BaseSpacing.xxl - 2, bottom: BaseSpacing.md + 4, top: BaseSpacing.xxs + 1),
        child: PrimaryButton(
          label: 'Login',
          onPressed: () => Get.toNamed(Routes.authTabView),
        ),
      );
    }

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(left: BaseSpacing.xxl - 2, right: BaseSpacing.xxl - 2, bottom: BaseSpacing.md + 4, top: BaseSpacing.xxs + 1),
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
                  Text(
                    controller.productQty.value.toString(),
                    style: BaseTypography.bodyLarge(color: AppColors.black).copyWith(fontWeight: FontWeight.w600),
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
                label: controller.isAddtoCartLoading.value ? "Adding..." : 'Add to cart',
                isLoading: controller.isAddtoCartLoading.value,
                onPressed: controller.isAddtoCartLoading.value ? null : () => controller.addToCart(),
              ),
            ),
          ),
        ],
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
    final String initials = displayName.trim().isNotEmpty ? displayName.trim()[0].toUpperCase() : 'S';
    final bool canVisit = slug != null && slug.isNotEmpty;

    return Semantics(
      button: canVisit,
      label: canVisit ? 'Sold by $displayName, visit store' : 'Sold by $displayName',
      child: GestureDetector(
        onTap: canVisit ? () => Get.toNamed(Routes.sellerStorefront, arguments: slug) : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xs + 2),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(BaseRadius.md),
            border: Border.all(color: AppColors.lightGrey.withOpacity(0.6)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(BaseRadius.pill),
                child: logo != null && logo.isNotEmpty
                    ? CommonImageView(url: logo, height: 40, width: 40, fit: BoxFit.cover)
                    : Container(
                        height: 40,
                        width: 40,
                        color: AppColors.primaryColor.withOpacity(0.1),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              SizedBox(width: BaseSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sold by', style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontWeight: FontWeight.w400)),
                    Text(
                      displayName,
                      style: BaseTypography.labelSmall(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              if (canVisit) ...[
                Text(
                  'Visit Store',
                  style: BaseTypography.labelSmall(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(width: BaseSpacing.xxs / 2),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primaryColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
