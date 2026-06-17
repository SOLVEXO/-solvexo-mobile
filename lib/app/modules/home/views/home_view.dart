import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/dynamic_shimmer.dart';
import 'package:book_store_app/app/components/no_signal_view.dart';
import 'package:book_store_app/app/components/shimmer/banner_shimmer.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/services/network_controller.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/banner_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/categories_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/home_search_bar.dart';
import 'package:book_store_app/app/modules/home/widgets/home_section_header.dart';
import 'package:book_store_app/app/modules/home/widgets/home_sort_chips.dart';
import 'package:book_store_app/app/modules/home/widgets/home_staff_picks.dart';
import 'package:book_store_app/app/modules/home/widgets/products_grid.dart';
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
        tooltip: 'AI Product Assistant',
        onPressed: () => Get.toNamed(Routes.CHAT),
        child: SvgIcon(
          assetName: AppIcons.assistantIcon,
          size: 30,
          color: AppColors.background.withOpacity(0.8),
        ),
      ),
      child: Obx(() {
        if (!networkController.isConnected.value) {
          return const NoSignalView();
        }

        final bool isLoading =
            controller.isLoading.value || categoryController.isLoading.value;

        return Stack(
          children: [
            CustomRefreshWrapper(
              onRefresh: controller.refreshHome,
              child: Scrollbar(
                trackVisibility: true,
                interactive: true,
                thickness: 3,
                radius: const Radius.circular(AppDimen.borderRadius),
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 16),

                    // ── Promotional banner ───────────────────────────────
                    isLoading
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimen.allPadding,
                            ),
                            child: BannerShimmer(),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimen.allPadding,
                            ),
                            child: BannerCarousel(),
                          ),

                    const SizedBox(height: 22),

                    // ── Browse by Category ───────────────────────────────
                    const HomeSectionHeader(title: 'Browse by Category'),
                    const SizedBox(height: 8),

                    isLoading
                        ? const DynamicShimmer(iscategories: true)
                        : categoryController.allCategoriesFlat.isEmpty
                        ? SizedBox(
                            height: height / 7,
                            child: const Center(
                              child: DynamicShimmer(iscategories: true),
                            ),
                          )
                        : CategoriesGrid(),

                    const SizedBox(height: 24),

                    // ── Trending Now ─────────────────────────────────────
                    const HomeSectionHeader(
                      title: 'Trending Now',
                      viewMore: true,
                    ),

                    // ── Search bar ───────────────────────────────────────
                    const HomeSearchBar(),
                    const SizedBox(height: 12),
                    // Sort chips
                    const HomeSortChips(),

                    const SizedBox(height: 12),

                    // Products grid / shimmer / empty
                    isLoading
                        ? const DynamicShimmer(isproducts: true)
                        : _ProductsSection(controller: controller),

                    const SizedBox(height: 24),

                    // ── Staff Picks ──────────────────────────────────────
                    const HomeSectionHeader(title: 'Staff Picks'),
                    const SizedBox(height: 12),

                    const HomeStaffPicks(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Login nudge for guests
            if (profileController.user.isNull)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(child: LoginSignupCard()),
              ),
          ],
        );
      }),
    );
  }
}

// ─── Products section (grid + load-more + empty state) ───────────────────────

class _ProductsSection extends StatelessWidget {
  final HomeController controller;
  const _ProductsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEmpty = controller.filteredProducts.isEmpty;
      final isFetching = controller.isFetchingProducts.value;

      if (isEmpty && !isFetching) {
        return SizedBox(
          height: 240,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(
                  assetName: AppIcons.shoppingBag,
                  size: 64,
                  color: AppColors.greySwatch400,
                ),
                const SizedBox(height: 12),
                const CustomText(
                  text: 'No products found',
                  fontSize: AppFontSize.small,
                  color: AppColors.gray600,
                ),
                const SizedBox(height: 4),
                const CustomText(
                  text: 'Try a different category or search term',
                  fontSize: AppFontSize.verySmall,
                  color: AppColors.lightGrey7,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          const ProductsGrid(),
          const SizedBox(height: 16),

          if (controller.hasMoreProducts.value && !isFetching)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimen.allPadding,
              ),
              child: AppButton(
                onPressed: controller.loadMoreProducts,
                label: 'Load More Products',
              ),
            ),

          if (isFetching)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
        ],
      );
    });
  }
}
