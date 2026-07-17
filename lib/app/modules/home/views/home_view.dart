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
import 'package:book_store_app/app/modules/home/widgets/home_greeting_header.dart';
import 'package:book_store_app/app/modules/home/widgets/home_search_filter_row.dart';
import 'package:book_store_app/app/modules/home/widgets/home_section_header.dart';
import 'package:book_store_app/app/modules/home/widgets/home_staff_picks.dart';
import 'package:book_store_app/app/modules/home/widgets/products_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/top_stores_row.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/base/base_view.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends BaseView<HomeController> {
  const HomeView({super.key});

  // `HomeView` is embedded directly as a bottom-nav tab (see
  // `BottomNavController.screens`), not only reached via `Routes.mainHome`'s
  // `HomeBinding` — self-registering here keeps it working either way,
  // matching the original `Get.put(HomeController())` field-initializer
  // behaviour `BaseView`'s `Get.find`-only `controller` getter replaced.
  @override
  HomeController get controller {
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController());
    return Get.find<HomeController>();
  }

  // Guarded the same way as `controller` above — these three were previously
  // unconditional `Get.put(...)`, which replaces the live singleton (losing
  // its state) every single time `buildBody` runs, e.g. on every return to
  // this tab. `isRegistered` makes them behave like `Get.find` once bound.
  CategoryController get _categoryController {
    if (!Get.isRegistered<CategoryController>()) Get.put(CategoryController());
    return Get.find<CategoryController>();
  }

  ProfileController get _profileController {
    if (!Get.isRegistered<ProfileController>()) Get.put(ProfileController());
    return Get.find<ProfileController>();
  }

  NetworkController get _networkController {
    if (!Get.isRegistered<NetworkController>()) Get.put(NetworkController());
    return Get.find<NetworkController>();
  }

  @override
  Color? get backgroundColor => AppColors.background;

  // @override
  // Widget? buildFloatingActionButton(BuildContext context) {
  //   return FloatingActionButton(
  //     backgroundColor: AppColors.primaryColor,
  //     tooltip: 'AI Product Assistant',
  //     onPressed: () => Get.toNamed(Routes.CHAT),
  //     child: SvgIcon(
  //       assetName: AppIcons.assistantIcon,
  //       size: 30,
  //       color: AppColors.background.withOpacity(0.8),
  //     ),
  //   );
  // }

  @override
  Widget buildBody(BuildContext context) {
    final categoryController = _categoryController;
    final profileController = _profileController;
    final networkController = _networkController;

    return Obx(() {
      if (!networkController.isConnected.value) {
        return const NoSignalView();
      }

      final bool isLoading =
          controller.isLoading.value || categoryController.isLoading.value;

      return Stack(
        children: [
          CustomRefreshWrapper(
            onRefresh: controller.refreshHome,
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // ── Greeting ──────────────────────────────────────────
                const HomeGreetingHeader(),

                SizedBox(height: BaseSpacing.xs),

                // ── Search + filter ───────────────────────────────────
                const HomeSearchFilterRow(),

                SizedBox(height: BaseSpacing.lg),

                // ── Browse by Category ───────────────────────────────
                const HomeSectionHeader(title: 'Browse by Category'),
                CategoriesGrid(),

                SizedBox(height: BaseSpacing.lg),

                // ── Promotional banner ───────────────────────────────
                isLoading ? BannerShimmer() : BannerCarousel(),

                // SizedBox(height: BaseSpacing.sm),

                // ── Top Stores ────────────────────────────────────────
                HomeSectionHeader(
                  title: 'Top Stores',
                  viewMore: true,
                  onViewMore: () => Get.toNamed(Routes.storesView),
                ),

                // SizedBox(height: BaseSpacing.sm),
                TopStoresRow(),

                SizedBox(height: BaseSpacing.sm),

                // ── Trending Now ─────────────────────────────────────
                const HomeSectionHeader(
                  title: 'Trending near you',
                  viewMore: true,
                ),

                // SizedBox(height: BaseSpacing.sm),
                isLoading
                    ? const DynamicShimmer()
                    : _ProductsSection(controller: controller),

                SizedBox(height: BaseSpacing.lg),

                // ── Staff Picks ──────────────────────────────────────
                const HomeSectionHeader(title: 'Staff Picks'),

                const HomeStaffPicks(),

                SizedBox(height: BaseSpacing.xxl),
              ],
            ),
          ),

          if (profileController.user.isNull)
            Positioned(
              left: BaseSpacing.sm,
              right: BaseSpacing.sm,
              bottom: BaseSpacing.sm,
              child: SafeArea(child: LoginSignupCard()),
            ),
        ],
      );
    });
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
                SizedBox(height: BaseSpacing.sm),
                CustomText(
                  text: 'No products found',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                ),
                SizedBox(height: BaseSpacing.xxs),
                CustomText(
                  text: 'Try a different category or search term',
                  color: AppColors.lightGrey7,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          const ProductsGrid(),
          SizedBox(height: BaseSpacing.md),
          if (controller.hasMoreProducts.value && !isFetching)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimen.allPadding,
              ),
              child: OutlineButton(
                onPressed: controller.loadMoreProducts,
                label: 'Load More Products',
              ),
            ),
          if (isFetching)
            Padding(
              padding: EdgeInsets.all(BaseSpacing.lg),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    });
  }
}
