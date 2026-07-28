import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/dynamic_shimmer.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:book_store_app/app/modules/trending_products/controllers/trending_products_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "See All" destination for Home's "Trending near you" section — same
/// product feed (newest-first, no category filter), plus a real server-side
/// paginated search box on top, visually matching `HomeSearchBar`.
class TrendingProductsView extends StatelessWidget {
  TrendingProductsView({super.key});
  final TrendingProductsController c = Get.put(TrendingProductsController());

  static const double _gridHPad = BaseSpacing.md - 1;
  static const double _crossGap = BaseSpacing.sm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: 'Trending near you'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimen.allPadding,
              0,
              AppDimen.allPadding,
              BaseSpacing.md,
            ),
            child: _SearchBar(controller: c),
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: DynamicShimmer(),
                );
              }

              if (c.products.isEmpty) {
                return _EmptyState(hasQuery: c.searchQuery.value.isNotEmpty);
              }

              return CustomRefreshWrapper(
                onRefresh: () => c.fetchProducts(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: BaseSpacing.xl),
                  child: Column(
                    children: [
                      SizedBox(height: BaseSpacing.xs),
                      _ProductGrid(controller: c),
                      SizedBox(height: BaseSpacing.md),
                      if (c.totalCount.value > 0)
                        CustomText(
                          text:
                              'Showing ${c.products.length} of ${c.totalCount.value} products',
                          color: AppColors.gray600,
                          fontSize: AppFontSize.tiny,
                        ),
                      SizedBox(height: BaseSpacing.sm),
                      if (c.hasMore.value)
                        OutlineButton(
                          onPressed: c.isFetchingMore.value
                              ? null
                              : c.loadMoreProducts,
                          isLoading: c.isFetchingMore.value,
                          label: 'Load More',
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          expand: false,
                          compact: true,
                        )
                      else
                        CustomText(
                          text: "You've reached the end",
                          color: AppColors.lightGrey7,
                          fontSize: AppFontSize.tiny,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Search bar — visually matches HomeSearchBar exactly ────────────────────

class _SearchBar extends StatelessWidget {
  final TrendingProductsController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.allPadding),
      ),
      child: CustomTextField(
        isDecoration: false,
        controller: controller.searchTextCtrl,
        onChanged: controller.onSearchChanged,
        isborder: true,
        hintText: 'Search products…',
        borderBorderradius: AppDimen.borderRadius,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        prefixIcon: SvgIcon(
          assetName: AppIcons.searchIcon,
          size: 20,
          color: AppColors.iosGrey,
        ),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: controller.clearSearch,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm),
                    child: const SvgIcon(
                      assetName: AppIcons.cross,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              : SizedBox(width: BaseSpacing.sm),
        ),
      ),
    );
  }
}

// ─── Product grid — same responsive column/cell logic as Home's ProductsGrid ─

class _ProductGrid extends StatelessWidget {
  final TrendingProductsController controller;
  const _ProductGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;

        int cols = 2;
        if (totalWidth >= 600) cols = 3;
        if (totalWidth >= 900) cols = 4;

        final double gridWidth =
            totalWidth - TrendingProductsView._gridHPad * 2;
        final double cellWidth =
            (gridWidth - TrendingProductsView._crossGap * (cols - 1)) / cols;
        final double cellHeight = cellWidth * 1.55;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TrendingProductsView._gridHPad,
          ),
          child: Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: BaseSpacing.md - 2,
                crossAxisSpacing: TrendingProductsView._crossGap,
                mainAxisExtent: cellHeight,
              ),
              itemBuilder: (_, i) =>
                  ProductCard(product: controller.products[i], index: i),
            ),
          ),
        );
      },
    );
  }
}

// ─── Empty state — same visual language as Home's ───────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgIcon(
            assetName: AppIcons.shoppingBag,
            size: 64,
            color: AppColors.greySwatch400,
          ),
          SizedBox(height: BaseSpacing.sm),
          CustomText(
            text: 'No products found',
            color: AppColors.gray600,
            fontSize: AppFontSize.tiny,
          ),
          SizedBox(height: BaseSpacing.xxs),
          CustomText(
            text: hasQuery
                ? 'Try a different search term'
                : 'Check back soon for new arrivals',
            color: AppColors.lightGrey7,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
