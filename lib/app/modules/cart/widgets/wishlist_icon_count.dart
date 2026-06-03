import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistIconCount extends StatelessWidget {
  const WishlistIconCount({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomIconButton(
          onPressed: () => Get.toNamed(Routes.WISHLIST),
          assetName: AppIcons.heartIcon,
          isPadding: true,
          size: 22,
        ),
        Obx(
          () => controller.wishlistController.count < 1
              ? SizedBox.shrink()
              : Positioned(
                  top: -6,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Obx(
                      () => CustomText(
                        text: "${controller.wishlistController.count}",
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
