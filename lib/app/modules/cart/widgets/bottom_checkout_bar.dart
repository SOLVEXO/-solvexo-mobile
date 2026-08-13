import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_user_greeting.dart';
import 'package:book_store_app/app/data/services/currency_controller.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomCheckoutBar extends StatelessWidget {
  BottomCheckoutBar({super.key});
  final controller = Get.find<CartController>();

  CurrencyController get currencyController {
    if (!Get.isRegistered<CurrencyController>()) {
      Get.put(CurrencyController(), permanent: true);
    }
    return Get.find<CurrencyController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? ShimmerUserGreeting()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl + 1, vertical: BaseSpacing.xl),
              decoration: BoxDecoration(color: AppColors.white, boxShadow: BaseShadows.forLevel(BaseElevation.level3)),
              child: Row(
                spacing: BaseSpacing.xl,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: controller.selectAll.value,
                        onChanged: (v) => controller.toggleSelectAll(v!),
                      ),
                      CustomText(
                        text: "All",
                        color: AppColors.black,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "Sub Total",
                        color: AppColors.black,
                        fontSize: AppFontSize.extraSmall,
                      ),
                      CustomText(
                        text: currencyController.format(controller.subtotal.value, controller.selectedCurrency),
                        color: AppColors.black,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTextStyles.monoFontFamily,
                      ),
                    ],
                  ),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: (controller.subtotal.value == 0 || controller.isCheckingOut.value)
                          ? null
                          : controller.proceedToCheckout,
                      isLoading: controller.isCheckingOut.value,
                      label: controller.isCheckingOut.value ? 'Creating checkout…' : 'Checkout',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
