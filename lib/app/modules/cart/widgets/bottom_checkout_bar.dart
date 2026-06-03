import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_user_greeting.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomCheckoutBar extends StatelessWidget {
  BottomCheckoutBar({super.key});
  final controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? ShimmerUserGreeting()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [BoxShadow(color: AppColors.black12, blurRadius: 10)],
              ),
              child: Row(
                spacing: 20,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: controller.selectAll.value,
                        onChanged: (v) => controller.toggleSelectAll(v!),
                      ),
                      CustomText(
                        text: "All",
                        fontSize: AppFontSize.regular,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const CustomText(text: "Sub Total"),
                      CustomText(
                        text: "\$ ${controller.subtotal.toStringAsFixed(2)}",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  Expanded(
                    child: AppButton(
                      onPressed: controller.subtotal.value == 0
                          ? null
                          : () {
                              Get.toNamed(
                                Routes.checkoutView,
                                arguments: controller.cartItems,
                              );
                            },
                      label: "Checkout",
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
