import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/app/modules/product_details/widgets/product_detail_shimmer.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsView extends StatelessWidget {
  ProductDetailsView({super.key});

  // ── Controllers ────────────────────────────────────────────────────────
  // ProductDetailController reads productId from Get.arguments in onInit
  final controller = Get.put(ProductDetailController());
  final profileController = Get.put(ProfileController());
  final bottombarcontroller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final date = DateTime.now().day;
    final month = DateTime.now().month;
    final year = DateTime.now().year;

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
          CustomIconButton(
            onPressed: () => Get.toNamed(Routes.searchView),
            assetName: AppIcons.searchIcon,
            size: AppFontSize.extraLarge,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
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
                  size: AppFontSize.extraLarge,
                  color: AppColors.gray600,
                ),
                const SizedBox(height: 12),
                CustomText(
                  text: 'Product not found',
                  fontSize: AppFontSize.regular,
                  color: AppColors.gray600,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                width: double.infinity,
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name + actions ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            text: product.name,
                            fontSize: AppFontSize.medium,
                            fontWeight: FontWeight.w600,
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
                          CustomText(
                            text: 'Stock (${controller.displayStock})',
                            fontSize: AppFontSize.small2,
                            color: controller.inStock
                                ? AppColors.green2
                                : AppColors.red,
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    // ── Seller name ─────────────────────────────────────
                    if (product.sellerId.isNotEmpty)
                      Row(
                        children: [
                          CustomText(
                            text: 'Sold by: ',
                            fontSize: AppFontSize.small2,
                            color: AppColors.gray600,
                          ),
                          CustomText(
                            text: product.sellerId,
                            fontSize: AppFontSize.small2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),

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
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: variants
                                  .where(
                                    (v) =>
                                        v.color != null && v.color!.isNotEmpty,
                                  )
                                  .map((v) {
                                    final isSelected =
                                        controller.selectedVariant.value?.id ==
                                        v.id;
                                    return GestureDetector(
                                      onTap: () => controller.selectVariant(v),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                              : AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : AppColors.lightGrey,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: CustomText(
                                          text: v.color!,
                                          fontSize: AppFontSize.tiny,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ],

                          // Sizes
                          if (product.availableSizes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            titleText('Size'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: variants
                                  .where(
                                    (v) => v.size != null && v.size!.isNotEmpty,
                                  )
                                  .map((v) {
                                    final isSelected =
                                        controller.selectedVariant.value?.id ==
                                        v.id;
                                    final outOfStock = v.stock == 0;
                                    return GestureDetector(
                                      onTap: outOfStock
                                          ? null
                                          : () => controller.selectVariant(v),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: outOfStock
                                              ? AppColors.lightGrey.withOpacity(
                                                  0.3,
                                                )
                                              : isSelected
                                              ? AppColors.primaryColor
                                              : AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : AppColors.lightGrey,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: CustomText(
                                          text: v.size!,
                                          fontSize: AppFontSize.tiny,
                                          fontWeight: FontWeight.w600,
                                          color: outOfStock
                                              ? AppColors.gray600
                                              : isSelected
                                              ? AppColors.white
                                              : AppColors.textPrimary,
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
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: CustomText(
                                      text: 'SKU: ${v.sku}',
                                      fontSize: AppFontSize.verySmall,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: v.stock > 0
                                            ? AppColors.green2.withOpacity(0.10)
                                            : AppColors.red.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: CustomText(
                                        text: v.stock > 0
                                            ? '${v.stock} in stock'
                                            : 'Out of stock',
                                        fontSize: AppFontSize.verySmall,
                                        fontWeight: FontWeight.w600,
                                        color: v.stock > 0
                                            ? AppColors.green2
                                            : AppColors.red,
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
                      fontSize: AppFontSize.small2,
                    ),

                    // ── Rating + sold row ───────────────────────────────
                    Row(
                      spacing: 5,
                      children: [
                        SvgIcon(
                          assetName: AppIcons.fillStar,
                          size: AppFontSize.small,
                        ),
                        CustomText(
                          text: product.averageRating.toStringAsFixed(1),
                          fontSize: AppFontSize.small2,
                          fontWeight: FontWeight.w600,
                        ),
                        const VerticalDivider(
                          color: AppColors.black,
                          width: 1,
                          thickness: 2,
                        ),
                        CustomText(
                          text: '${product.purchaseCount} Sold',
                          fontSize: AppFontSize.small2,
                        ),
                      ],
                    ),

                    const Divider(),

                    // ── Reviews expansion tile ──────────────────────────
                    _expandTile(
                      'Reviews',
                      false.obs,
                      Column(
                        children: [
                          CustomText(
                            textAlign: TextAlign.center,
                            color: AppColors.gray600,
                            fontSize: AppFontSize.small2,
                            text: '"Very good product — exactly as described!"',
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: CustomText(text: 'Ahmed Hussain'),
                            subtitle: SizedBox(
                              height: 20,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: SvgIcon(
                                      assetName: AppIcons.fillStar,
                                      size: 15,
                                    ),
                                  );
                                },
                              ),
                            ),
                            trailing: CustomText(
                              text: 'Order $date-$month-$year',
                            ),
                          ),
                        ],
                      ),
                    ),

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
    return CustomText(
      text: text,
      color: color,
      fontSize: AppFontSize.medium,
      fontWeight: FontWeight.w800,
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
        children: [Padding(padding: const EdgeInsets.all(12), child: content)],
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────

  Widget _bottomBar(Size size, BuildContext context) {
    if (profileController.user.value.isNull) {
      return Container(
        color: AppColors.white,
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 5),
        child: AppButton(
          label: 'Login',
          onPressed: () => Get.toNamed(Routes.authTabView),
        ),
      );
    }

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 5),
      child: Row(
        spacing: 10,
        children: [
          // ── Qty stepper ───────────────────────────────────────────
          Obx(
            () => Container(
              width: size.width / 2.5,
              padding: const EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textPrimary, width: 0.4),
                borderRadius: BorderRadius.circular(10),
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
                    fontSize: AppFontSize.regular,
                    fontWeight: FontWeight.w600,
                  ),
                  IconButton(
                    onPressed: controller.increaseQty,
                    icon: const Icon(Icons.add, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
          ),

          // ── Add to cart ───────────────────────────────────────────
          Expanded(
            child: Obx(
              () => AppButton(
                label: controller.isAddtoCartLoading.value
                    ? "Adding..."
                    : 'Add to cart',
                onPressed: () => controller.isAddtoCartLoading.value
                    ? null
                    : controller.addToCart(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
