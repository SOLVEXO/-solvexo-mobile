import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/dynamic_shimmer.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/no_signal_view.dart';
import 'package:book_store_app/app/components/shimmer/banner_shimmer.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/services/network_controller.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/banner_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/categories_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/products_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/sub_category_grid.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});
  final controller = Get.put(HomeController());
  final categoryController = Get.put(CategoryController());
  final profileController = Get.put(ProfileController());
  final networkController = Get.put(NetworkController());
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return BaseViewScreen(
      backgroundColor: AppColors.background,
      safeAreaTop: true,
      showCustomAppBar: true,
      height: 60,
      mainAppBar: true,
      horizontalPadding: false,
      verticalPadding: false,
      showBottomBar: false,
      bottomBarShadow: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        tooltip: 'Here for Help to find Products.',
        onPressed: () => Get.toNamed(Routes.CHAT),
        child: SvgIcon(
          assetName: AppIcons.assistantIcon,
          size: 30,
          color: AppColors.background.withOpacity(0.8),
        ),
      ),
      child: Obx(() {
        // ── No internet ────────────────────────────────────────────────
        if (!networkController.isConnected.value) {
          return const NoSignalView();
        }
        final bool isLoading =
            controller.isLoading.value || categoryController.isLoading.value;

        return Stack(
          children: [
            CustomRefreshWrapper(
              onRefresh: () => controller.refreshHome(),
              child: Scrollbar(
                trackVisibility: true,
                interactive: true,
                thickness: 4,
                radius: const Radius.circular(AppDimen.borderRadius),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    // parent: ClampingScrollPhysics(),
                  ),
                  children: [
                    // ── Delivery address ─────────────────────────────
                    // DeliveryAddress(),
                    const SizedBox(height: AppDimen.allPadding),

                    // ── Banner ───────────────────────────────────────
                    isLoading ? BannerShimmer() : BannerCarousel(),

                    const SizedBox(height: AppDimen.allPadding),
                    titleText("Browse by Category"),
                    // ── Categories ───────────────────────────────────
                    isLoading
                        ? const DynamicShimmer(iscategories: true)
                        : categoryController.allCategoriesFlat.isEmpty
                        ? SizedBox(
                            height: height / 3.25,
                            child: const Center(
                              child: DynamicShimmer(iscategories: true),
                            ),
                          )
                        : CategoriesGrid(),
                    const SizedBox(height: AppDimen.allPadding),
                    // ── White card — subcategories + tabs + products ──
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          titleText("Trending Products", viewMore: true),
                          // ── Sub categories ─────────────────────────
                          isLoading
                              ? const DynamicShimmer(issubcategories: true)
                              : SubCategoryGrid(),

                          const SizedBox(height: 10),
                          const Divider(thickness: 0.5),
                          const SizedBox(height: 10),

                          // // ── Tab header ─────────────────────────────
                          // isLoading
                          //     ? const DynamicShimmer(istabs: true)
                          //     : TabHeader(),

                          // const SizedBox(height: 5),

                          // ── Products ───────────────────────────────
                          isLoading
                              ? const DynamicShimmer(isproducts: true)
                              : _ProductsSection(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // // ── Login card overlay ───────────────────────────────────
            profileController.user.isNull
                ? Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: SafeArea(child: LoginSignupCard()),
                  )
                : SizedBox.shrink(),
          ],
        );
      }),
    );
  }

  Widget titleText(String title, {bool viewMore = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: AppDimen.bottomPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w600,
          ),
          viewMore
              ? TextButton(
                  onPressed: () {},
                  child: CustomText(
                    text: "See All",
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

// ─── Products section (extracted to avoid Obx nesting issues) ─────────────

class _ProductsSection extends StatelessWidget {
  final HomeController controller;
  const _ProductsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Empty state
      if (controller.filteredProducts.isEmpty &&
          !controller.isFetchingProducts.value) {
        return SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: AppColors.greySwatch400,
                ),
                const SizedBox(height: 16),
                CustomText(
                  text:
                      'No ${controller.tabs[controller.tabIndex.value]} found',
                  fontSize: 16,
                  color: AppColors.gray600,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          ProductsGrid(),
          const SizedBox(height: 20),

          // Load more button
          if (controller.hasMoreProducts.value &&
              !controller.isFetchingProducts.value)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: AppButton(
                onPressed: controller.loadMoreProducts,
                label: 'Load More Products',
              ),
            ),

          // Fetching more indicator
          if (controller.isFetchingProducts.value)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      );
    });
  }
}
