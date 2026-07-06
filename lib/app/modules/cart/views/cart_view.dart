import 'package:book_store_app/app/components/custom_app_bar_two.dart';
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
import 'package:book_store_app/core/base/base_view.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

class CartView extends BaseView<CartController> {
  const CartView({super.key});

  // `CartView` is embedded directly as a bottom-nav tab, not only reached
  // via `Routes.cartView`'s `CartBinding` — self-registering keeps it
  // working either way (it happened to be safe before only because
  // `BottomNavController` separately puts a `CartController` of its own).
  @override
  CartController get controller {
    if (!Get.isRegistered<CartController>()) Get.put(CartController());
    return Get.find<CartController>();
  }

  ProfileController get _profileController => Get.put(ProfileController());

  @override
  Color? get backgroundColor => AppColors.white;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) => CustomAppBarTwo(
        title: "Cart",
        actions: [WishlistIconCount()],
      );

  @override
  Widget buildBody(BuildContext context) {
    final profileController = _profileController;

    return Obx(() {
      if (profileController.user.isNull) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(height: Get.height / 12),
              LoginSignupCard(),
              const Spacer(),
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
        return const EmptyCartText();
      }
      return CustomRefreshWrapper(
        onRefresh: controller.refreshCart,
        child: Column(
          children: [
            _selectAllRow(),
            const Divider(height: 1, thickness: 0.5),
            Expanded(
              child: Scrollbar(
                trackVisibility: true,
                interactive: true,
                thickness: 4,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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
    });
  }

  Widget _selectAllRow() {
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
          onPressed: () => controller.showWishListConformation(),
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
