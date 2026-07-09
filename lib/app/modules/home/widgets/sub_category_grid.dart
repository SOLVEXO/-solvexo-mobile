import 'package:book_store_app/app/components/sub_category_card.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubCategoryGrid extends StatelessWidget {
  const SubCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive columns
        int crossAxisCount = 2;
        if (width > 600) crossAxisCount = 3; // tablet
        if (width > 900) crossAxisCount = 4; // large screens

        // Responsive aspect ratio
        final aspectRatio = width < 400 ? 1.2 : 1.45;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md - 1),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: BaseSpacing.md - 2,
              crossAxisSpacing: BaseSpacing.md - 2,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, i) {
              final item = controller.items[i];

              return SubCategoryCard(
                title: item["title"] as String,
                price: item["price"] as String,
                image: item["image"] as String,
                color: item["color"] as Color,
              );
            },
          ),
        );
      },
    );
  }
}
