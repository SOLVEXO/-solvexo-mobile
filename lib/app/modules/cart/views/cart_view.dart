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
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/core/widgets/wave_bottom_nav_bar.dart';
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

  // Was unconditional `Get.put(ProfileController())` — same
  // singleton-replacement issue fixed elsewhere: this ran every time the
  // Cart tab was shown, wiping the shared ProfileController.
  ProfileController get _profileController {
    if (!Get.isRegistered<ProfileController>())
      Get.put(ProfileController(), permanent: true);
    return Get.find<ProfileController>();
  }

  @override
  Color? get backgroundColor => AppColors.white;

  // `BaseView`'s default `SafeArea` reserves bottom padding matching the
  // floating bottom-nav bar's full height, which would otherwise push the
  // checkout bar up behind the nav bar's overlap zone. Clearance is added
  // manually below (after `BottomCheckoutBar`) instead.
  @override
  bool get useSafeArea => false;

  // `MainView` (the bottom-nav shell) is only ever reached via
  // `Get.offAllNamed`, so when Cart is the active tab it sits at the root
  // of the nav stack and `canPop` is false. When opened via a cart icon
  // elsewhere (`Get.toNamed(Routes.cartView)`), it's pushed on top, so
  // `canPop` is true — that's the signal for showing a back button.
  @override
  PreferredSizeWidget buildAppBar(BuildContext context) => CustomAppBarTwo(
    title: "Cart",
    showLeading: Navigator.canPop(context),
    actions: [WishlistIconCount()],
  );

  Future<void> _onLoggedIn() async {
    await _profileController.refreshProfile();
    await controller.refreshCart();
  }

  @override
  Widget buildBody(BuildContext context) {
    final profileController = _profileController;

    return SafeArea(
      bottom: false,
      child: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerEffect(itemCount: 3);
        }
        if (controller.cartItems.isEmpty) {
          // Guests with an empty local cart get the same nudge + recommendations
          // as before; a guest with items in their cart falls through below to
          // see the actual cart (guest-allowed) with just a slim login nudge —
          // checkout itself is the protected action, not viewing the cart.
          if (profileController.user.isNull) {
            // Scaffold's body slot already gives this Column bounded height —
            // no extra ConstrainedBox/SingleChildScrollView wrapper needed
            // (that combination produces "RenderFlex... unbounded height
            // constraints" once an Expanded child is involved).
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: BaseSpacing.xl,
                        ),
                        child: LoginSignupCard(onLoggedIn: _onLoggedIn),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    BaseSpacing.xl,
                    0,
                    BaseSpacing.xl,
                    BaseSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Featured Items you may like",
                        color: AppColors.black,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w600,
                      ),
                      RecommendedProductList(),
                    ],
                  ),
                ),
              ],
            );
          }
          return const EmptyCartText();
        }
        return CustomRefreshWrapper(
          onRefresh: controller.refreshCart,
          child: Column(
            children: [
              if (profileController.user.isNull)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    BaseSpacing.md,
                    BaseSpacing.sm,
                    BaseSpacing.md,
                    0,
                  ),
                  child: LoginSignupCard(onLoggedIn: _onLoggedIn),
                ),
              _selectAllRow(),
              const Divider(height: 1, thickness: 0.5),
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
                  padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Featured Items you may like",
                        color: AppColors.black,
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w600,
                      ),
                      RecommendedProductList(),
                    ],
                  ),
                ),
              BottomCheckoutBar(),
              SizedBox(height: WaveBottomNavBar.totalHeight),
            ],
          ),
        );
      }),
    );
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
        CustomText(
          text: "Select All",
          color: AppColors.black,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w500,
        ),
        const Spacer(),
        GhostButton(
          label: "Move to Wishlist",
          onPressed: () => controller.showWishListConformation(
            onRightButtonTap: () => controller.moveSelectedToWishlist(),
          ),
        ),
        CustomText(
          text: '|',
          color: AppColors.lightGrey,
          fontSize: AppFontSize.tiny,
        ),
        GhostButton(
          label: "Delete",
          onPressed: () {
            controller.showDeleteConfirmation(
              onLeftButtonTap: () => controller.showWishListConformation(),
              onRightButtonTap: () => controller.clearCart(),
            );
          },
        ),
      ],
    );
  }
}
