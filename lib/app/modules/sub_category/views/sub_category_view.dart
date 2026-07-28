import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/custom_bread_crumbs.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/cart/widgets/wishlist_icon_count.dart';
import 'package:book_store_app/app/modules/sub_category/controller/sub_category_controller.dart';
import 'package:book_store_app/app/modules/sub_category/widgets/floating_item_row.dart';
import 'package:book_store_app/app/modules/home/widgets/banner_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SubCategoryView extends StatelessWidget {
  const SubCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller reads arguments itself in onInit — intentionally
    // re-created fresh per navigation, since each subcategory page needs
    // its own state.
    final c = Get.put(SubCategoryController());

    return BaseViewScreen(
      showCustomAppBar: true,
      horizontalPadding: false,
      verticalPadding: false,
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFloatingButton(),
      screenName: c.categoryName,
      actions: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: CartIconWithCount(color: AppColors.white, size: 25),
        ),
        SizedBox(width: BaseSpacing.xxs + 3),
        WishlistIconCount(),
      ],
      child: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: c.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: _SubCategoryBody(c: c),
        ),
      ),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────────────────

class _SubCategoryBody extends StatelessWidget {
  final SubCategoryController c;
  const _SubCategoryBody({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: BaseSpacing.xs + 2),
        // ── Banner ──────────────────────────────────────────────────
        const BannerCarousel(),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: BaseSpacing.xs + 2),

              // ── Breadcrumb ────────────────────────────────────────
              CustomBreadCrumbs(categoryName: c.categoryName),

              SizedBox(height: BaseSpacing.xl - BaseSpacing.xxs),

              // ── Sub-category chips ────────────────────────────────
              _SectionHeader(title: 'Shop by Subcategory'),
              SizedBox(height: BaseSpacing.sm),

              _SubCategoryChips(c: c),
              SizedBox(height: BaseSpacing.xl),

              // ── Products header ───────────────────────────────────
              Row(
                children: [
                  _SectionHeader(title: 'All Products'),
                  const Spacer(),
                  Obx(
                    () => CustomText(
                      text: '${c.products.length} items',
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: BaseSpacing.sm),

              // ── Product grid ──────────────────────────────────────
              _ProductGrid(c: c),

              SizedBox(height: BaseSpacing.xxl + BaseSpacing.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(BaseRadius.xs),
          ),
        ),
        SizedBox(width: BaseSpacing.xs),
        CustomText(
          text: title,
          color: AppColors.textPrimary,
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

// ─── Sub-category chips ─────────────────────────────────────────────────────
class _ChipData {
  final String label;
  final String? imageUrl;
  final int index;

  const _ChipData({
    required this.label,
    required this.imageUrl,
    required this.index,
  });
}

class _SubCategoryChips extends StatelessWidget {
  final SubCategoryController c;
  const _SubCategoryChips({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Build chip list: "All" + each sub-category
      final items = <_ChipData>[
        _ChipData(label: 'All', imageUrl: null, index: 0),
        ...c.subCategories.asMap().entries.map(
          (e) => _ChipData(
            label: e.value.name,
            imageUrl: e.value.image,
            index: e.key + 1,
          ),
        ),
      ];

      if (items.length == 1) {
        // No sub-categories — hide the strip
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs / 2),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.sm),
          itemBuilder: (_, i) {
            return Obx(() {
              final chip = items[i];
              final isSelected = c.selectedSubCategoryIndex.value == chip.index;
              return Semantics(
                button: true,
                selected: isSelected,
                label: chip.label,
                child: GestureDetector(
                  onTap: () => c.selectSubCategory(chip.index),
                  child: AnimatedContainer(
                    duration: BaseMotion.normal,
                    width: 72,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor.withOpacity(0.08)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(BaseRadius.lg),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image / icon container
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryColor.withOpacity(0.12)
                                : AppColors.primaryColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(
                              BaseRadius.md - 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              BaseRadius.md - 1,
                            ),
                            child:
                                chip.imageUrl != null &&
                                    chip.imageUrl!.isNotEmpty
                                ? CommonImageView(
                                    url: chip.imageUrl,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    chip.index == 0
                                        ? Icons.grid_view_rounded
                                        : Icons.category_rounded,
                                    color: AppColors.primaryColor,
                                    size: 26,
                                  ),
                          ),
                        ),
                        SizedBox(height: BaseSpacing.xxs + 1),
                        CustomText(
                          text: chip.label,
                          maxLines: 2,
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.textPrimary,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }
}

// ─── Product Grid ──────────────────────────────────────────────────────────

class _ProductGrid extends StatelessWidget {
  final SubCategoryController c;
  const _ProductGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoadingProducts.value && c.products.isEmpty) {
        return _buildShimmerGrid();
      }

      if (c.products.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: [
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.60,
            ),
            itemBuilder: (_, i) =>
                ProductCard(product: c.products[i], index: i),
          ),

          // ── Load more button ─────────────────────────────────────
          if (c.hasMoreProducts.value) ...[
            SizedBox(height: BaseSpacing.md),
            _LoadMoreButton(c: c),
          ],
        ],
      );
    });
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.lightGrey.withOpacity(0.5),
        highlightColor: AppColors.lightGrey.withOpacity(0.9),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(BaseRadius.lg),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxl + BaseSpacing.sm),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(BaseRadius.xxl),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: BaseSpacing.xs + 2),
            CustomText(
              text: 'No products found',
              color: AppColors.textPrimary,
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: BaseSpacing.xxs + 2),
            CustomText(
              text: 'Try a different subcategory',
              color: AppColors.gray600,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Load More Button ──────────────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  final SubCategoryController c;
  const _LoadMoreButton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Semantics(
        button: true,
        label: c.isLoadingProducts.value
            ? 'Loading more products'
            : 'Load more products',
        child: GestureDetector(
          onTap: c.isLoadingProducts.value ? null : c.loadMoreProducts,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(BaseRadius.md),
              border: Border.all(color: AppColors.primaryColor, width: 1.5),
            ),
            child: Center(
              child: c.isLoadingProducts.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : CustomText(
                      text: 'Load More',
                      color: AppColors.primaryColor,
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
