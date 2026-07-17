import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared wishlist heart toggle — the notched-corner button sitting inside
/// an image box's top-right notch. Used on both `ProductCard` (grid/list)
/// and `ProductDetailsView`'s hero gallery, which previously each carried
/// their own copy-pasted version of this button.
class WishlistHeartButton extends StatelessWidget {
  final String productId;
  final String variantId;
  final double size;

  const WishlistHeartButton({
    super.key,
    required this.productId,
    required this.variantId,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Obx(
      () => GestureDetector(
        onTap: () => controller.addorRemoveWishList(productId, variantId),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: SvgIcon(
            assetName: controller.isFavourite(productId)
                ? AppIcons.heartFill
                : AppIcons.heartIcon,
            size: size * 13 / 28,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
