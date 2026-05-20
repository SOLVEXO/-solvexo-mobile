import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/widgets/category_bread_crumb.dart';
import 'package:book_store_app/app/modules/category/widgets/category_search_bar.dart';
import 'package:book_store_app/app/modules/category/widgets/category_search_list.dart';
import 'package:book_store_app/app/modules/home/widgets/category_item.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CategoryView extends StatelessWidget {
  CategoryView({super.key});

  final controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    // final hasChildren = controller.categoryWithChildren.value == null;
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
              return Column(
                children: [
                  CategoryBreadcrumb(),
                  Expanded(child: CategoryContent()),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
      if (controller.isLoading.value || controller.isLoadingDetails.value) {
        return const CategoryShimmerGrid();
      }

      final isRoot = controller.selectedCategory.value == null;
      final items = isRoot
          ? controller.rootCategories
          : controller.categoryWithChildren.value?.children ??
                controller.selectedCategory.value!.children;

      if (items.isEmpty) return _buildEmptyState();

      return CustomRefreshWrapper(
        onRefresh: controller.refresh,
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.category_outlined,
              size: AppFontSize.extraLarge,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomText(
            text: 'No categories found',
            fontSize: AppFontSize.regular,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: 'Check back later',
            fontSize: AppFontSize.small2,
            color: AppColors.gray600,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 7),
              Container(
                height: 10,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Left Menu ─────────────────────────────────────────────────────────────

class CategoryLeftMenu extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryLeftMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: controller.rootCategories.length,
          itemBuilder: (_, i) {
            final item = controller.rootCategories[i];
            final isSelected = controller.selectedCategory.value?.id == item.id;

            return GestureDetector(
              onTap: () {
                controller.selectCategory(item);
                controller.fetchCategoryDetails(item.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor.withOpacity(0.08)
                            : AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: CommonImageView(
                          url: item.image,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      text: item.name,
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.blackColor,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Right Content ─────────────────────────────────────────────────────────

class CategoryRightContent extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryRightContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;

      if (selected == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 48,
                color: AppColors.lightGrey,
              ),
              const SizedBox(height: 12),
              CustomText(
                text: 'Select a category',
                fontSize: AppFontSize.small2,
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        );
      }

      final children =
          controller.categoryWithChildren.value?.children ?? selected.children;

      if (controller.isLoadingDetails.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
            strokeWidth: 2.5,
          ),
        );
      }

      if (children.isEmpty) {
        return Center(
          child: CustomText(
            text: 'No subcategories',
            fontSize: AppFontSize.small2,
            color: AppColors.gray600,
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: children.length,
        itemBuilder: (_, i) {
          final item = children[i];
          return _ModernCategoryCard(
            title: item.name,
            image: item.image,
            onTap: () {
              controller.selectCategory(item);
              controller.fetchCategoryDetails(item.id);
            },
          );
        },
      );
    });
  }
}

class _ModernCategoryCard extends StatelessWidget {
  final String title;
  final String? image;
  final VoidCallback onTap;

  const _ModernCategoryCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: CommonImageView(
                  url: image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomText(
                text: title,
                fontSize: AppFontSize.regular,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
