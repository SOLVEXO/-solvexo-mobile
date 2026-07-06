import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_effect.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/myorders/views/order_tracking_view.dart';
import 'package:book_store_app/app/modules/myorders/widgets/my_order_card.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/base/base_view.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_orders_controller.dart';

class MyOrdersView extends BaseView<MyOrdersController> {
  const MyOrdersView({super.key});

  // `MyOrdersView` is embedded directly as a bottom-nav tab, not only
  // reached via `Routes.myOrdersView`'s `ProfileMyordersBinding` —
  // self-registering keeps it working either way, matching the original
  // `Get.put(MyOrdersController())` field-initializer behaviour.
  @override
  MyOrdersController get controller {
    if (!Get.isRegistered<MyOrdersController>()) Get.put(MyOrdersController());
    return Get.find<MyOrdersController>();
  }

  @override
  Color? get backgroundColor => AppColors.background;

  @override
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: Container(
        padding: EdgeInsets.only(top: Get.height / 14, bottom: 13, left: 15, right: 15),
        decoration: const BoxDecoration(gradient: AppColors.appbarGradient),
        child: CustomTextField(
          hintText: "Search Order",
          isborder: true,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          borderBorderradius: AppDimen.borderRadius,
          prefixIcon: SvgIcon(assetName: AppIcons.searchIcon, color: AppColors.gray600),
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(controller.tabs.length, (i) {
                  final isActive = controller.selectedTab.value == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => controller.changeTab(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryColor : AppColors.background,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: isActive ? AppColors.primaryColor : AppColors.lightGrey2),
                        ),
                        child: CustomText(
                          text: controller.tabs[i],
                          fontSize: AppFontSize.verySmall,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.white : AppColors.greyDefault,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        const Divider(height: 0, thickness: 1, color: AppColors.background),
        Expanded(
          child: Obx(() {
            // Fixed: these branches previously built a widget without
            // returning it, so guests never saw the login prompt and the
            // loading shimmer never actually appeared — both fall through
            // to (an empty) order list instead.
            if (!controller.loginUser.value) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    LoginSignupCard(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  ],
                ),
              );
            }

            if (controller.isLoading.value) {
              return ShimmerEffect();
            }

            if (controller.filteredOrders.isEmpty) {
              return const BaseEmptyView(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet',
                subtitle: 'Orders you place will show up here.',
              );
            }

            return CustomRefreshWrapper(
              onRefresh: () => controller.refreshOrders(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                itemCount: controller.filteredOrders.length,
                itemBuilder: (_, i) {
                  final order = controller.filteredOrders[i];
                  return GestureDetector(
                    onTap: () => Get.to(() => OrderTrackingView(index: i)),
                    child: MyOrderCard(order: order),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
