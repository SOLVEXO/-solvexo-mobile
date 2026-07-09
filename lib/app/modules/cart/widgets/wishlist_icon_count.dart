import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistIconCount extends StatelessWidget {
  const WishlistIconCount({super.key});

  @override
  Widget build(BuildContext context) {
    // Was `Get.put(CartController())` — this widget sits in the app bar of
    // Cart, Category, Sub-category, and Product Details screens, so it
    // replaced the app-wide CartController singleton on *every single
    // navigation* to any of those screens, discarding live cart state each
    // time. Guarded the same way as the other fixes in this pass.
    if (!Get.isRegistered<CartController>()) Get.put(CartController());
    final controller = Get.find<CartController>();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(right: BaseSpacing.sm),
          padding: EdgeInsets.all(BaseSpacing.xxs - 1),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          ),
          child: CustomIconButton(
            onPressed: () => Get.toNamed(Routes.WISHLIST),
            assetName: AppIcons.heartIcon,
            color: AppColors.white,
            size: 22,
          ),
        ),
        Obx(
          () => controller.wishlistController.count < 1
              ? const SizedBox.shrink()
              : Positioned(
                  top: -6,
                  right: BaseSpacing.xs,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs, vertical: BaseSpacing.xxs / 2),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColorLight,
                      borderRadius: BorderRadius.circular(BaseRadius.xxl),
                      boxShadow: BaseShadows.forLevel(BaseElevation.level1),
                    ),
                    alignment: Alignment.center,
                    child: Obx(
                      () => Text(
                        "${controller.wishlistController.count}",
                        style: BaseTypography.labelSmall(color: AppColors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
