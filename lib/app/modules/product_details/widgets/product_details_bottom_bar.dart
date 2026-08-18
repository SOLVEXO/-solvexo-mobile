import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Quantity stepper + "Add to cart" (or a "Login" prompt for guests).
class ProductDetailsBottomBar extends StatelessWidget {
  final ProductDetailController controller;
  final ProfileController profileController;
  final Size size;

  const ProductDetailsBottomBar({
    super.key,
    required this.controller,
    required this.profileController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // if (profileController.user.value.isNull) {
    //   return Container(
    //     color: AppColors.white,
    //     padding: EdgeInsets.only(
    //       left: BaseSpacing.xxl - 2,
    //       right: BaseSpacing.xxl - 2,
    //       bottom: BaseSpacing.md + 4,
    //       top: BaseSpacing.xxs + 1,
    //     ),
    //     child: PrimaryButton(
    //       label: 'Login',
    //       onPressed: () => Get.toNamed(Routes.authTabView),
    //     ),
    //   );
    // }

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(
        left: BaseSpacing.xxl - 2,
        right: BaseSpacing.xxl - 2,
        bottom: BaseSpacing.md + 4,
        top: BaseSpacing.xxs + 1,
      ),
      child: Row(
        spacing: BaseSpacing.sm,
        children: [
          // ── Qty stepper ───────────────────────────────────────────
          Obx(
            () => Container(
              width: size.width / 2.5,
              padding: EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textPrimary, width: 0.4),
                borderRadius: BorderRadius.circular(BaseRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: controller.decreaseQty,
                    icon: Icon(Icons.remove, color: AppColors.primaryColor),
                  ),
                  CustomText(
                    text: controller.productQty.value.toString(),
                    color: AppColors.black,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w600,
                  ),
                  IconButton(
                    onPressed: controller.increaseQty,
                    icon: Icon(Icons.add, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
          ),

          // ── Add to cart ───────────────────────────────────────────
          Expanded(
            child: Obx(
              () => PrimaryButton(
                label: controller.isAddtoCartLoading.value
                    ? "Adding..."
                    : controller.inStock
                    ? 'Add to cart'
                    : 'Out of stock',
                isLoading: controller.isAddtoCartLoading.value,
                onPressed:
                    (controller.isAddtoCartLoading.value || !controller.inStock)
                    ? null
                    : () => controller.addToCart(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
