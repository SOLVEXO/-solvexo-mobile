import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

/// Home's "Browse by Category" rail — flat circular chips (image + label),
/// no card shell/shadow, matching the light, modern marketplace look. Owns
/// its own loading/empty rendering so `HomeView` doesn't have to juggle
/// shimmer-vs-empty-vs-content branching inline.
class CategoriesGrid extends StatelessWidget {
  CategoriesGrid({super.key});

  static const double _railHeight = 92;
  static const double _avatarSize = 60;

  final CategoryController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const _CategoriesRailShimmer();
      }

      final items = controller.categoryTrees;
      if (items.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: _railHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.md),
          itemBuilder: (_, i) {
            final item = items[i];
            return _CategoryChip(
              title: item.name,
              image: item.image,
              onTap: () => Get.toNamed(Routes.categoryView),
            );
          },
        ),
      );
    });
  }
}

class _CategoryChip extends StatelessWidget {
  final String title;
  final String? image;
  final VoidCallback onTap;

  const _CategoryChip({required this.title, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: CategoriesGrid._avatarSize,
              height: CategoriesGrid._avatarSize,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor.withOpacity(0.12)),
              ),
              child: ClipOval(
                child: CommonImageView(url: image, width: CategoriesGrid._avatarSize, height: CategoriesGrid._avatarSize, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: BaseSpacing.xs),
            CustomText(
              text: title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              color: AppColors.textPrimary,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesRailShimmer extends StatelessWidget {
  const _CategoriesRailShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CategoriesGrid._railHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.md),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: AppColors.lightGrey.withOpacity(0.5),
          highlightColor: AppColors.lightGrey.withOpacity(0.9),
          child: SizedBox(
            width: 68,
            child: Column(
              children: [
                Container(
                  width: CategoriesGrid._avatarSize,
                  height: CategoriesGrid._avatarSize,
                  decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                ),
                SizedBox(height: BaseSpacing.xs),
                Container(height: 10, width: 44, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
