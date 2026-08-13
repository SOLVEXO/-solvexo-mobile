import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/services/currency_controller.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Selected-variant price (with optional struck-through compare-at price)
/// plus an in-stock/out-of-stock pill.
class ProductPriceStockRow extends StatelessWidget {
  final ProductDetailController controller;
  const ProductPriceStockRow({super.key, required this.controller});

  CurrencyController get _currencyController {
    if (!Get.isRegistered<CurrencyController>()) {
      Get.put(CurrencyController(), permanent: true);
    }
    return Get.find<CurrencyController>();
  }

  @override
  Widget build(BuildContext context) {
    final currencyController = _currencyController;
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (controller.hasDiscount) ...[
            CustomText(
              text: currencyController.format(
                controller.displayCompareAtPrice!,
                controller.displayCurrency,
              ),
              color: AppColors.gray600,
              fontSize: AppFontSize.extraSmall,
              fontWeight: FontWeight.w500,
              textDecoration: TextDecoration.lineThrough,
              fontFamily: AppTextStyles.monoFontFamily,
            ),
            SizedBox(width: BaseSpacing.xs),
          ],
          CustomText(
            text: currencyController.format(
              controller.displayPrice,
              controller.displayCurrency,
            ),
            color: AppColors.primaryColor,
            fontSize: AppFontSize.regular,
            fontWeight: FontWeight.w800,
            fontFamily: AppTextStyles.monoFontFamily,
          ),
          SizedBox(width: BaseSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSpacing.xs + 2,
              vertical: BaseSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: (controller.inStock ? AppColors.green2 : AppColors.red)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(BaseRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  controller.inStock
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 13,
                  color: controller.inStock ? AppColors.green2 : AppColors.red,
                ),
                SizedBox(width: BaseSpacing.xxs / 2),
                CustomText(
                  text: !controller.inStock
                      ? 'Out of stock'
                      : (controller.product.value?.isDigital ?? false) ||
                            (controller.selectedVariant.value?.isUnlimited ??
                                false)
                      ? 'In stock'
                      : 'In stock (${controller.displayStock})',
                  color: controller.inStock ? AppColors.green2 : AppColors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
