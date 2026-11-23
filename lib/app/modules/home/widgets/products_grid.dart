import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key}) : sliver = false;

  /// Lazy variant for a CustomScrollView (R3): only visible tiles are built,
  /// so "Load more" pages do not rebuild/lay out every earlier card.
  const ProductsGrid.sliver({super.key}) : sliver = true;
  final bool sliver;

  static const double _gridHPad = BaseSpacing.md - 1;
  static const double _crossGap = BaseSpacing.sm;

  static SliverGridDelegate delegateFor(double totalWidth) {
    int cols = 2;
    if (totalWidth >= 600) cols = 3;
    if (totalWidth >= 900) cols = 4;
    final double cellWidth =
        (totalWidth - _gridHPad * 2 - _crossGap * (cols - 1)) / cols;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      mainAxisSpacing: BaseSpacing.md - 2,
      crossAxisSpacing: _crossGap,
      mainAxisExtent: cellWidth * 1.55,
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    if (sliver) {
      return SliverLayoutBuilder(
        builder: (context, c) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: _gridHPad),
          sliver: Obx(
            () => SliverGrid.builder(
              itemCount: controller.filteredProducts.length,
              gridDelegate: delegateFor(c.crossAxisExtent),
              itemBuilder: (_, i) => ProductCard(
                product: controller.filteredProducts[i],
                index: i,
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;

        int cols = 2;
        if (totalWidth >= 600) cols = 3;
        if (totalWidth >= 900) cols = 4;

        final double gridWidth = totalWidth - _gridHPad * 2;
        final double cellWidth = (gridWidth - _crossGap * (cols - 1)) / cols;

        // Card height = 1.55× width → image occupies exactly 50% via Expanded
        final double cellHeight = cellWidth * 1.55;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gridHPad),
          // Reactivity lives here, inside the widget's own build — the caller
          // instantiates this as `const ProductsGrid()`, and a const instance
          // is `identical` across parent rebuilds, so Flutter's element diff
          // skips rebuilding it entirely unless the observable read is inside
          // its own Obx (Obx subscribes directly and rebuilds independently
          // of whether the parent widget instance changed).
          child: Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: BaseSpacing.md - 2,
                crossAxisSpacing: _crossGap,
                mainAxisExtent: cellHeight,
              ),
              itemBuilder: (_, i) => ProductCard(
                product: controller.filteredProducts[i],
                index: i,
              ),
            ),
          ),
        );
      },
    );
  }
}
