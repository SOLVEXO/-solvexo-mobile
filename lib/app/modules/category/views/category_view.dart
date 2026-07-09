import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/widgets/category_search_bar.dart';
import 'package:book_store_app/app/modules/category/widgets/category_search_list.dart';
import 'package:book_store_app/app/modules/home/widgets/category_item.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

/// Browse main categories. Tapping any category navigates straight to
/// SubCategoryView, which shows that category's own subcategories as filter
/// chips over a single product grid — so there's no in-app drill-down here.
class CategoryView extends StatelessWidget {
  CategoryView({super.key});

  // Guarded — was unconditional `Get.put`, which replaced the shared
  // `CategoryController` singleton (also used by Home's "Browse by
  // Category" section) every time this screen was opened.
  CategoryController get controller {
    if (!Get.isRegistered<CategoryController>()) Get.put(CategoryController());
    return Get.find<CategoryController>();
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBarTwo(title: "Categories"),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CategoryShimmerGrid();
              }
              if (controller.searchQuery.value.isNotEmpty) {
                return CategorySearchList(controller: controller);
              }
              return CategoryContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(0, 0, 0, BaseSpacing.sm),
      child: CategorySearchBar(controller: controller),
    );
  }
}

// ─── Category Content ──────────────────────────────────────────────────────

class CategoryContent extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const CategoryShimmerGrid();
      }

      final items = controller.rootCategories;

      if (items.isEmpty) return _buildEmptyState();

      return CustomRefreshWrapper(
        onRefresh: controller.refresh,
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xl),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (_, i) {
            final item = items[i];
            return CategoryItem(
              title: item.name,
              image: item.image,
              onTap: () => controller.selectCategory(item),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(BaseRadius.xxl),
            ),
            child: Icon(Icons.category_outlined, size: 40, color: AppColors.primaryColor),
          ),
          SizedBox(height: BaseSpacing.md),
          CustomText(
            text: 'No categories found',
            color: AppColors.textPrimary,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(height: BaseSpacing.xxs + 2),
          CustomText(
            text: 'Check back later',
            color: AppColors.gray600,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer ───────────────────────────────────────────────────────────────

class CategoryShimmerGrid extends StatelessWidget {
  const CategoryShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xl),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: AppColors.lightGrey.withOpacity(0.5),
          highlightColor: AppColors.lightGrey.withOpacity(0.8),
          child: Column(
            children: [
              Container(
                height: 68,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg)),
              ),
              SizedBox(height: BaseSpacing.xxs - 1),
              Container(
                height: 10,
                width: 50,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.xs)),
              ),
              SizedBox(height: BaseSpacing.xxs),
              Container(
                height: 10,
                width: 36,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.xs)),
              ),
            ],
          ),
        );
      },
    );
  }
}
