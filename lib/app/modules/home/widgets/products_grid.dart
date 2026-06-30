import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key});

  static const double _gridHPad = 15.0;
  static const double _crossGap = 12.0;

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

        // Card height = 1.55× width → image occupies exactly 50% via Expanded
        final double cellHeight = cellWidth * 1.55;

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
