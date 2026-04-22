import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/widgets/category_bread_crumb.dart';
import 'package:book_store_app/app/modules/category/widgets/category_search_bar.dart';
import 'package:book_store_app/app/modules/home/widgets/category_item.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CategoryView extends StatelessWidget {
  CategoryView({super.key});

  final controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      appBar: CustomAppBarTwo(title: "Categories"),

      body: Column(
        children: [
          CategorySearchBar(controller: controller),

          /// 🔥 BREADCRUMB
          CategoryBreadcrumb(),

          /// 🔥 CONTENT
          Expanded(child: CategoryContent()),
        ],
      ),
    );
  }
}

class CategoryContent extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      /// 🔥 LOADING SHIMMER
      if (controller.isLoading.value || controller.isLoadingDetails.value) {
        return const CategoryShimmerGrid();
      }

      /// ROOT
      final isRoot = controller.selectedCategory.value == null;

      final items = isRoot
          ? controller.rootCategories
          : controller.categoryWithChildren.value?.children ??
                controller.selectedCategory.value!.children;

      if (items.isEmpty) {
        return const Center(child: Text("No categories found"));
      }

      return CustomRefreshWrapper(
        onRefresh: controller.refresh,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 🔥 Daraz style
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.60,
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
}

// class CategoryGridTile extends StatelessWidget {
//   final CategoryModel item;
//   final VoidCallback onTap;

//   const CategoryGridTile({super.key, required this.item, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(AppDimen.borderRadius),
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 10,
//               color: Colors.black.withOpacity(0.05),
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: CommonImageView(
//                 url: item.image,
//                 // width: 50,
//                 radius: BorderRadius.circular(AppDimen.borderRadius),
//               ),
//             ),
//             const SizedBox(height: 8),
//             CustomText(
//               text: item.name,
//               maxLines: 2,
//               textAlign: TextAlign.center,
//               // fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class CategoryShimmerGrid extends StatelessWidget {
  const CategoryShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: AppColors.lightGrey.withOpacity(0.5),
          highlightColor: AppColors.lightGrey.withOpacity(0.8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class CategoryLeftMenu extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryLeftMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: controller.rootCategories.length,
          itemBuilder: (_, i) {
            final item = controller.rootCategories[i];

            final isSelected = controller.selectedCategory.value?.id == item.id;

            return GestureDetector(
              onTap: () {
                controller.selectCategory(item);

                /// optional API call if needed
                controller.fetchCategoryDetails(item.id);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryColor.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    CommonImageView(
                      url: item.image,
                      width: 55,
                      height: 55,
                      radius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 6),
                    CustomText(
                      text: item.name,
                      textAlign: TextAlign.center,
                      fontSize: 11,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
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

class CategoryRightContent extends StatelessWidget {
  final controller = Get.find<CategoryController>();

  CategoryRightContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;

      if (selected == null) {
        return const Center(child: Text("Select a category"));
      }

      /// 🔥 Prefer API details if available
      final children =
          controller.categoryWithChildren.value?.children ?? selected.children;

      if (controller.isLoadingDetails.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (children.isEmpty) {
        return const Center(child: Text("No subcategories"));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: children.length,
        itemBuilder: (_, i) {
          final item = children[i];

          return CategoryCard(
            title: item.name,
            image: item.image,
            onTap: () {
              /// 👇 Drill down
              controller.selectCategory(item);
              controller.fetchCategoryDetails(item.id);
            },
          );
        },
      );
    });
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String? image;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            CommonImageView(
              url: image,
              width: 60,
              height: 60,
              radius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                text: title,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
