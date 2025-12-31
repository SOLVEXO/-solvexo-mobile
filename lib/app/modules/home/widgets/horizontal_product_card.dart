import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/search/controllers/search_controller.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HorizontalProductCard extends StatelessWidget {
  final int index;
  final String prodName, prodDesc, price, reviews, prodImage;
  final double ratings;
  HorizontalProductCard({
    super.key,
    required this.prodName,
    required this.prodDesc,
    required this.price,
    required this.reviews,
    required this.ratings,
    required this.prodImage,
    required this.index,
  });
  final controller = Get.find<SearchBarController>();
  final categoryController = Get.find<CategoryController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        categoryController.openProductDetails(
          controller.filteredProducts[index],
        );
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 95,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SvgIcon(assetName: prodImage, size: 100),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: prodName,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                    text: prodDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return SvgIcon(
                                assetName: AppIcons.fillStar,
                                size: AppFontSize.small2,
                              );
                            },
                          ),
                        ),
                        Expanded(child: CustomText(text: "($reviews)")),
                      ],
                    ),
                  ),
                  CustomText(
                    text: "\$ $price",
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            Obx(
              () => IconButton(
                onPressed: () {
                  controller.favouriteMap[prodName] =
                      !controller.favouriteMap[prodName]!;
                },
                icon: SvgIcon(
                  assetName: controller.favouriteMap[prodName]!
                      ? AppIcons.heartFill
                      : AppIcons.heartIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
