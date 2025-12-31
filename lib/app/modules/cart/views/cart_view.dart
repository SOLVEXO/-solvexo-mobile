import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/modules/cart/widgets/bottom_checkout_bar.dart';
import 'package:book_store_app/app/modules/cart/widgets/cart_item_widget.dart';
import 'package:book_store_app/app/modules/cart/widgets/empty_cart_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/cart_controller.dart';

class CartView extends StatelessWidget {
  CartView({super.key});
  final controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    // final cartItem = controller.cartItems[index];
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Cart"),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return EmptyCartText();
        }
        return Column(
          children: [
            /// 🔹 Select All Row
            selectAllRow(),

            const Divider(height: 1, thickness: 0.5),

            /// 🔹 Cart Items List
            Expanded(
              child: ListView.builder(
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = controller.cartItems[index];

                  return Column(
                    children: [
                      CartItemWidget(item: cartItem),
                      const Divider(height: 1, thickness: 0.5),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Featured Items you may like",
                    fontSize: AppFontSize.regular,
                    fontWeight: FontWeight.w600,
                  ),
                  RecommendedProductList(),
                ],
              ),
            ),
            BottomCheckoutBar(),
          ],
        );
      }),
    );
  }

  Widget selectAllRow() {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: controller.selectAll.value,
            onChanged: (v) => controller.toggleSelectAll(v!),
          ),
        ),
        const CustomText(text: "Select All", fontSize: AppFontSize.regular),
        const Spacer(),
        TextButton(
          onPressed: () {
            controller.showWishListConformation();
          },
          child: CustomText(
            text: "Move to Wishlist",
            fontSize: AppFontSize.small2,
            color: AppColors.primaryColor,
          ),
        ),
        CustomText(text: '|', color: AppColors.lightGrey),
        TextButton(
          onPressed: () {
            controller.showDeleteConfirmation(controller.removeSelectedItems);
          },
          child: CustomText(
            text: "Delete",
            color: AppColors.primaryColor,
            fontSize: AppFontSize.small2,
          ),
        ),
      ],
    );
  }
}
