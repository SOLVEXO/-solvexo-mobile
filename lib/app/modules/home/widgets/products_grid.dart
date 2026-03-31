import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsGrid extends StatelessWidget {
  ProductsGrid({super.key});
  final HomeController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.filteredProducts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: w >= 390 ? 2 : 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (_, i) {
          final item = controller.filteredProducts[i];
          // Your existing ProductCard widget
          // It will now receive ProductModel from backend
          return ProductCard(product: item);
        },
      ),
    );
  }
}
