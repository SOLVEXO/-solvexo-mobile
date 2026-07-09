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
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_orders_controller.dart';

class MyOrdersView extends BaseView<MyOrdersController> {
  const MyOrdersView({super.key});

  @override
  MyOrdersController get controller {
    if (!Get.isRegistered<MyOrdersController>()) Get.put(MyOrdersController());
    return Get.find<MyOrdersController>();
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimen.allPadding),
          child: CustomTextField(
            isborder: true,
            fillColor: AppColors.textfldFillColor,
            prefixIcon: SvgIcon(
              assetName: AppIcons.searchIcon,
              color: AppColors.lightGrey,
              size: 22,
            ),
            hintText: "Search",
          ),
        ),
        Obx(
          () => Container(
            color: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm - 1),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md - 1),
              child: Row(
                children: List.generate(controller.tabs.length, (i) {
                  final isActive = controller.selectedTab.value == i;
                  return Padding(
                    padding: EdgeInsets.only(right: BaseSpacing.xs),
                    child: Semantics(
                      button: true,
                      selected: isActive,
                      label: controller.tabs[i],
                      child: GestureDetector(
                        onTap: () => controller.changeTab(i),
                        child: AnimatedContainer(
                          duration: BaseMotion.normal,
                          curve: Curves.easeInOut,
                          constraints: const BoxConstraints(minHeight: 40),
                          padding: EdgeInsets.symmetric(
                            horizontal: BaseSpacing.md + 2,
                            vertical: BaseSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryColor
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(
                              BaseRadius.pill,
                            ),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primaryColor
                                  : AppColors.lightGrey2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: CustomText(
                            text: controller.tabs[i],
                            color: isActive
                                ? AppColors.white
                                : AppColors.greyDefault,
                            fontSize: AppFontSize.tiny,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
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
                    SizedBox(height: BaseSpacing.xl),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: BaseSpacing.md - 1,
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
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
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
