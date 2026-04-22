import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/category_item.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesGrid extends StatelessWidget {
  CategoriesGrid({super.key});
  final CategoryController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height / 3.29,
      child: Scrollbar(
        scrollbarOrientation: ScrollbarOrientation.bottom,
        trackVisibility: true,
        interactive: true,
        thickness: 4,
        radius: const Radius.circular(10),
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          itemCount: controller.categoryTrees.length,
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 rows FIXED!
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (_, i) {
            final item = controller.categoryTrees[i];
            return GestureDetector(
              onTap: () {
                Get.toNamed(Routes.categoryView);
                // // Filter products by this category
                // controller.tabIndex.value =
                //     i + 1; // +1 because "All Products" is index 0
                // controller.fetchProducts();
              },
              child: CategoryItem(
                image: item.image, // Backend image URL
                title: item.name, // Backend category name
              ),
            );
          },
        ),
      ),
    );
  }
}
