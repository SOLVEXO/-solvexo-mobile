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
        height: 250,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: controller.products.length,

          itemBuilder: (_, index) {
            final item = controller.products[index];
            return ProductCard(
              index: index,
              image: item.image,
              name: item.name,
              price: item.price.toString(),
              rating: item.rating,
              reviews: item.reviews.toString(),
              disc: item.description,
            );
          },
        ),
      ),
    );
  }
}
