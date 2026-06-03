import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_effect.dart';
import 'package:book_store_app/app/modules/cart/widgets/bottom_checkout_bar.dart';
import 'package:book_store_app/app/modules/cart/widgets/cart_item_widget.dart';
import 'package:book_store_app/app/modules/cart/widgets/empty_cart_text.dart';
import 'package:book_store_app/app/modules/cart/widgets/wishlist_icon_count.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

class CartView extends StatelessWidget {
  CartView({super.key});

  final controller = Get.put(CartController());
  final profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    // final cartItem = controller.cartItems[index];
    return BaseViewScreen(
      screenName: "Cart",
      showCustomAppBar: true,
      horizontalPadding: false,
      verticalPadding: false,
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      actions: [WishlistIconCount()],
      child: Obx(() {
        if (profileController.user.isNull) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(height: Get.height / 12),
                LoginSignupCard(),
                Spacer(),
                Column(
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
              ],
            ),
          );
        }
        if (controller.isLoading.value) {
          return ShimmerEffect(itemCount: 3);
        }
        if (controller.cartItems.isEmpty) {
          return EmptyCartText();
        }
        return CustomRefreshWrapper(
          onRefresh: controller.refreshCart,
          child: Column(
            children: [
              /// 🔹 Select All Row
              selectAllRow(),
              const Divider(height: 1, thickness: 0.5),

              /// 🔹 Cart Items List
              Expanded(
                child: Scrollbar(
                  trackVisibility: true,
                  interactive: true,
                  thickness: 4,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
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
              ),
              if (controller.cartItems.length <= 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
          ),
        );
      }),
    );
  }

  Widget selectAllRow() {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            activeColor: AppColors.primaryColor,
            value: controller.selectAll.value,
            onChanged: (v) => controller.toggleSelectAll(v!),
          ),
        ),
        const CustomText(
          text: "Select All",
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.w500,
        ),
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
            controller.showDeleteConfirmation(
              onLeftButtonTap: () => controller.showWishListConformation(),
              onRightButtonTap: () => controller.clearCart(),
            );
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
