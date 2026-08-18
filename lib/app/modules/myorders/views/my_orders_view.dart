import 'package:book_store_app/app/components/app_search_field.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/shimmer/shimmer_effect.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/myorders/views/order_tracking_view.dart';
import 'package:book_store_app/app/modules/myorders/widgets/my_order_card.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/base_empty_view.dart';
import 'package:book_store_app/core/widgets/wave_bottom_nav_bar.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/my_orders_controller.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  MyOrdersController get controller {
    if (!Get.isRegistered<MyOrdersController>()) Get.put(MyOrdersController());
    return Get.find<MyOrdersController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Root of the nav stack (root `MainView` is only reached via
      // `Get.offAllNamed`) when Orders is the active bottom-nav tab, so
      // `canPop` is false there and true when pushed via
      // `Get.toNamed(Routes.myOrdersView)` from Profile/Notifications.
      appBar: CustomAppBarTwo(
        title: "My Orders",
        showLeading: Navigator.canPop(context),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Search + status filters — a single elevated block that
            // reads as "sticky" above the scrolling list beneath it ─────
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: BaseShadows.forLevel(BaseElevation.level2),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      BaseSpacing.md,
                      BaseSpacing.sm,
                      BaseSpacing.md,
                      BaseSpacing.xs,
                    ),
                    child: Obx(
                      () => AppSearchField(
                        controller: controller.searchController,
                        onChanged: controller.updateSearchQuery,
                        staticHint: 'Search by order # or product',
                        suffixIcon: controller.searchQuery.value.isEmpty
                            ? null
                            : GestureDetector(
                                onTap: () {
                                  controller.searchController.clear();
                                  controller.updateSearchQuery('');
                                },
                                child: const SvgIcon(
                                  assetName: AppIcons.cross,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                  Obx(
                    () => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.fromLTRB(
                        BaseSpacing.md,
                        0,
                        BaseSpacing.md,
                        BaseSpacing.sm + 1,
                      ),
                      child: Row(
                        children: List.generate(controller.tabs.length, (i) {
                          final isActive = controller.selectedTab.value == i;
                          final count = controller.tabCount(i);
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
                                  constraints: const BoxConstraints(
                                    minHeight: 36,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: BaseSpacing.sm + 2,
                                    vertical: BaseSpacing.xxs + 2,
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomText(
                                        text: controller.tabs[i],
                                        color: isActive
                                            ? AppColors.white
                                            : AppColors.greyDefault,
                                        fontSize: AppFontSize.tiny,
                                        fontWeight: isActive
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                      if (count > 0) ...[
                                        SizedBox(width: BaseSpacing.xxs),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.white.withOpacity(
                                                    0.24,
                                                  )
                                                : AppColors.lightGrey2,
                                            borderRadius: BorderRadius.circular(
                                              BaseRadius.pill,
                                            ),
                                          ),
                                          child: CustomText(
                                            text: '$count',
                                            color: isActive
                                                ? AppColors.white
                                                : AppColors.gray600,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                // Fixed: these branches previously built a widget without
                // returning it, so guests never saw the login prompt and the
                // loading shimmer never actually appeared — both fall through
                // to (an empty) order list instead.
                if (!controller.loginUser.value) {
                  // The `Expanded` above already gives this Column bounded
                  // height — no extra ConstrainedBox/SingleChildScrollView
                  // wrapper needed (that combination is what was producing
                  // "RenderFlex... unbounded height constraints" here).
                  return Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: BaseSpacing.xl,
                              ),
                              child: LoginSignupCard(
                                onLoggedIn: controller.fetchOrders,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          BaseSpacing.md - 1,
                          0,
                          BaseSpacing.md - 1,
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

                if (controller.isLoading.value) {
                  return ShimmerEffect();
                }

                if (controller.filteredOrders.isEmpty) {
                  final hasQuery = controller.searchQuery.value.isNotEmpty;
                  return BaseEmptyView(
                    icon: hasQuery
                        ? Icons.search_off_rounded
                        : Icons.receipt_long_outlined,
                    title: hasQuery ? 'No matching orders' : 'No orders yet',
                    subtitle: hasQuery
                        ? 'Try a different order # or product name.'
                        : 'Orders you place will show up here.',
                  );
                }

                return CustomRefreshWrapper(
                  onRefresh: () => controller.refreshOrders(),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppDimen.allPadding,
                      BaseSpacing.sm,
                      AppDimen.allPadding,
                      WaveBottomNavBar.totalHeight,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    itemCount: controller.filteredOrders.length,
                    itemBuilder: (_, i) {
                      final order = controller.filteredOrders[i];
                      return MyOrderCard(
                        order: order,
                        onTap: () => Get.to(() => OrderTrackingView(index: i)),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
