import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/models/storefront/store_list_item_model.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

/// Home's "Top Stores" row — sorted by rating then followers (see
/// `StoreService.getTopStores`). Structurally mirrors `CategoriesGrid`: owns
/// its own loading/empty rendering so `HomeView` doesn't have to branch.
class TopStoresRow extends StatelessWidget {
  TopStoresRow({super.key});

  static const double _cardWidth = 132;
  // Tight to the card's actual content (avatar + 3 text lines + padding) —
  // was 158, which left ~25px of dead space under every card.
  static const double _rowHeight = 136;

  final HomeController controller = Get.find();
  final CategoryController categoryController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Same combined flag Banner/Products gate on in HomeView, so every
      // section's shimmer appears and disappears together on load + refresh
      // instead of each section popping in independently.
      final isLoading = controller.isLoading.value || categoryController.isLoading.value;
      if (isLoading) {
        return const _TopStoresShimmer();
      }

      final stores = controller.topStores;
      if (stores.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: _rowHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
          itemCount: stores.length,
          separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.sm),
          itemBuilder: (_, i) => _TopStoreCard(store: stores[i]),
        ),
      );
    });
  }
}

class _TopStoreCard extends StatelessWidget {
  final StoreListItemModel store;
  const _TopStoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.sellerStorefront, arguments: {'slug': store.slug}),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: TopStoresRow._cardWidth,
        padding: EdgeInsets.all(BaseSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.md),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: CommonImageView(
                url: store.logo,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: BaseSpacing.xs),
            CustomText(
              text: store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              color: AppColors.textPrimary,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: BaseSpacing.xxs / 2),
            Row(
              children: [
                SvgIcon(assetName: AppIcons.fillStar, size: 12),
                SizedBox(width: BaseSpacing.xxs / 2),
                CustomText(
                  text: store.averageRating > 0
                      ? store.averageRating.toStringAsFixed(1)
                      : 'New',
                  color: AppColors.greyDefault,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
            SizedBox(height: BaseSpacing.xxs / 2),
            CustomText(
              text: '${store.followersCount} followers',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              color: AppColors.gray600,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors `CategoriesGrid`'s `_CategoriesRailShimmer` technique — individual
/// bone shapes (circle + text lines) matching the real card's layout, rather
/// than one flat block, so the shimmer's proportions match the loaded card.
class _TopStoresShimmer extends StatelessWidget {
  const _TopStoresShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TopStoresRow._rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
        itemCount: 4,
        separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.sm),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: AppColors.lightGrey.withOpacity(0.5),
          highlightColor: AppColors.lightGrey.withOpacity(0.9),
          child: Container(
            width: TopStoresRow._cardWidth,
            padding: EdgeInsets.all(BaseSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                ),
                SizedBox(height: BaseSpacing.xs),
                Container(height: 10, width: 84, color: AppColors.white),
                SizedBox(height: BaseSpacing.xxs),
                Container(height: 10, width: 56, color: AppColors.white),
                SizedBox(height: BaseSpacing.xxs),
                Container(height: 10, width: 70, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
