import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final int index;
  final String image, name, price, reviews, disc;
  final double rating;

  ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.disc,
    required this.index,
  });

  final controller = Get.find<HomeController>();
  final categoryController = Get.find<CategoryController>();
  @override
  Widget build(BuildContext context) {
    double radius = 15;
    return GestureDetector(
      onTap: () {
        categoryController.openProductDetails(
          categoryController.products[index],
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Stack(
                alignment: AlignmentGeometry.topRight,
                children: [
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: SvgIcon(assetName: image),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.favouriteMap[name] =
                          !controller.favouriteMap[name]!;
                    },
                    icon: SvgIcon(
                      assetName: controller.favouriteMap[name]!
                          ? AppIcons.heartFill
                          : AppIcons.heartIcon,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            CustomText(
              text: name,
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            CustomText(
              text: disc,
              fontSize: AppFontSize.small2,
              color: Colors.grey,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: SvgIcon(
                          assetName: AppIcons.fillStar,
                          size: AppFontSize.small,
                        ),
                      ),
                    ),
                  ),
                  CustomText(text: "($rating)"),
                ],
              ),
            ),
            CustomText(
              text: "\$ $price",
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7a73ff),
            ),
          ],
        ),
      ),
    );
  }
}
