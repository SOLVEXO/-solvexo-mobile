import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/search/controllers/search_controller.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HorizontalProductCard extends StatelessWidget {
  final ProductModel prod;
  final Function()? onTap;
  HorizontalProductCard({super.key, this.onTap, required this.prod});
  final controller = Get.find<SearchBarController>();
  final categoryController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: CommonImageView(url: prod.images.first, width: 50),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: prod.name,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                    text: prod.description,
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
                      ],
                    ),
                  ),
                  CustomText(
                    text: "\$ ${prod.price}",
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            // Obx(
            //   () => IconButton(
            //     onPressed: () {
            //       controller.favouriteMap[prod.name] =
            //           !controller.favouriteMap[prod.name]!;
            //     },
            //     icon: SvgIcon(
            //       assetName: controller.favouriteMap[prod.name]!
            //           ? AppIcons.heartFill
            //           : AppIcons.heartIcon,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
