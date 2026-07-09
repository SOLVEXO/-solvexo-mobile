import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductImageWithFavoriteButton extends StatelessWidget {
  const ProductImageWithFavoriteButton({
    super.key,
    required this.product,
    required this.index,
  });
  final ProductModel product;
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    double radius = AppDimen.borderRadius;
    return Obx(() {
      return Stack(
        children: [
          // Product Image
          AspectRatio(
            aspectRatio: 1.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: product.images.isNotEmpty
                  ? CommonImageView(
                      url: product.images.first,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      color: AppColors.greySwatch200,
                      child: Icon(
                        Icons.shopping_bag,
                        color: AppColors.greyDefault,
                        size: 40,
                      ),
                    ),
            ),
          ),

          // Favorite Button (Top Right) — IconButton already provides the
          // Material-standard 48x48 minimum touch target.
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                controller.addorRemoveWishList(
                  product.id,
                  product.variants[index].id,
                );
              },
              icon: SvgIcon(
                assetName: controller.isFavourite(product.id)
                    ? AppIcons.heartFill
                    : AppIcons.heartIcon,
              ),
            ),
          ),
        ],
      );
    });
  }
}
