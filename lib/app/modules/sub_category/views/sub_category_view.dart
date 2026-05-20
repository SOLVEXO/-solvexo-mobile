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
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class SubCategoryView extends StatelessWidget {
  const SubCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller reads arguments itself in onInit
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
      actions: [CartIconWithCount(), SizedBox(width: 7), WishlistIconCount()],
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
        // ── Banner ──────────────────────────────────────────────────
        BannerCarousel(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),

              // ── Breadcrumb ────────────────────────────────────────
              CustomBreadCrumbs(categoryName: c.categoryName),

              const SizedBox(height: 20),

              // ── Sub-category chips ────────────────────────────────
              _SectionHeader(title: 'Shop by Subcategory'),
              const SizedBox(height: 12),

              // _SubCategoryChips(c: c),
              _SubCategoryChips(c: c),
              const SizedBox(height: 24),

              // ── Products header ───────────────────────────────────
              Row(
                children: [
                  _SectionHeader(title: 'All Products'),
                  const Spacer(),
                  Obx(
                    () => CustomText(
                      text: '${c.products.length} items',
                      fontSize: AppFontSize.small2,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Product grid ──────────────────────────────────────
              _ProductGrid(c: c),

              const SizedBox(height: 80),
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        CustomText(
          text: title,
          fontSize: AppFontSize.medium,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}

// // ─── Sub-category chips ────────────────────────────────────────────────────
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
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            return Obx(() {
              final chip = items[i];
              final isSelected = c.selectedSubCategoryIndex.value == chip.index;
              return GestureDetector(
                onTap: () => c.selectSubCategory(chip.index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.08)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent,
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              chip.imageUrl != null && chip.imageUrl!.isNotEmpty
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
                                  size: AppFontSize.large,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        text: chip.label,
                        fontSize: AppFontSize.verySmall,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.textPrimary,
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center,
                      ),
                    ],
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
            const SizedBox(height: 16),
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: AppFontSize.extraLarge,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            CustomText(
              text: 'No products found',
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 6),
            CustomText(
              text: 'Try a different subcategory',
              fontSize: AppFontSize.small2,
              color: AppColors.gray600,
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
      () => GestureDetector(
        onTap: c.isLoadingProducts.value ? null : c.loadMoreProducts,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
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
                    fontSize: AppFontSize.regular,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
          ),
        ),
      ),
    );
  }
}
