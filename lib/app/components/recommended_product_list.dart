import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecommendedProductList extends StatelessWidget {
  const RecommendedProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    return Obx(
      () => SizedBox(
        height: Get.height / 2.7,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
          ),
          itemCount: controller.products.length,
          itemBuilder: (_, index) {
            final item = controller.products[index];
            return ProductCard(product: item);
          },
        ),
      ),
    );
  }
}
