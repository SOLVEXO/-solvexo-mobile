import 'package:book_store_app/app/components/custom_text.dart';
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
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
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
            SizedBox(width: 60),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text("Sub Total"),
                Text(
                  "\$ ${controller.subTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: controller.subTotal == 0
                    ? null
                    : () {
                        Get.toNamed(
                          Routes.checkoutView,
                          arguments: controller.cartItems,
                        );
                      },
                child: CustomText(
                  color: AppColors.background,
                  text: "Checkout",
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSize.regular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
