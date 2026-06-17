import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key});

  static const double _gridHPad = 15.0;
  static const double _crossGap = 12.0;

  // Text zone below image (no card padding since image is flush):
  //   top inset 9 + name 2×14px×1.4lh=40 + SizedBox(4) +
  //   sellerRow 14 + Spacer + price 22 + bottom inset 10  = ~99px + 16px buffer
  static const double _textZone = 115.0;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;

        int cols = 2;
        if (totalWidth >= 600) cols = 3;
        if (totalWidth >= 900) cols = 4;

        final double gridWidth = totalWidth - _gridHPad * 2;
        final double cellWidth =
            (gridWidth - _crossGap * (cols - 1)) / cols;

        // Image is AspectRatio(1.05) and flush to card edges
        final double imageHeight = cellWidth / 1.05;
        final double cellHeight = imageHeight + _textZone;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gridHPad),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.filteredProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 14,
              crossAxisSpacing: _crossGap,
              mainAxisExtent: cellHeight,
            ),
            itemBuilder: (_, i) => ProductCard(
              product: controller.filteredProducts[i],
              index: i,
            ),
          ),
        );
      },
    );
  }
}
