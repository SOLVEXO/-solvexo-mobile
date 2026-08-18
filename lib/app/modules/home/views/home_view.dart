import 'package:book_store_app/app/components/announcement_banner.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/dynamic_shimmer.dart';
import 'package:book_store_app/app/components/no_signal_view.dart';
import 'package:book_store_app/app/components/sell_on_solvexo_card.dart';
import 'package:book_store_app/app/components/shimmer/banner_shimmer.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/services/network_controller.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/banner_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/campaigns_section.dart';
import 'package:book_store_app/app/modules/home/widgets/categories_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/home_greeting_header.dart';
import 'package:book_store_app/app/modules/home/widgets/home_search_filter_row.dart';
import 'package:book_store_app/app/modules/home/widgets/home_section_header.dart';
import 'package:book_store_app/app/modules/home/widgets/platform_stats_strip.dart';
import 'package:book_store_app/app/modules/home/widgets/products_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/testimonials_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/top_stores_row.dart';
import 'package:book_store_app/app/modules/home/widgets/worksheet_trial_promo_card.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/base/base_view.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/wave_bottom_nav_bar.dart';
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
  // Registered `permanent: true` (like ProfileController — see that fix)
  // because `Get.offAllNamed(Routes.mainHome)` on logout tears down and
  // re-pushes this route: a non-permanent HomeController would get disposed
  // (including `searchTextCtrl`) by GetX's smart management right as the
  // fresh mainHome route remounts HomeView on top of it, crashing the search
  // bar with "TextEditingController used after being disposed".
  @override
  HomeController get controller {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    return Get.find<HomeController>();
  }

  // Guarded the same way as `controller` above — these three were previously
  // unconditional `Get.put(...)`, which replaces the live singleton (losing
  // its state) every single time `buildBody` runs, e.g. on every return to
  // this tab. `isRegistered` makes them behave like `Get.find` once bound.
  // `CategoryController` is also made permanent for the same reason as
  // `HomeController` above — it owns a `TextEditingController` and is shared
  // across Home/Category/Search/SubCategory.
  CategoryController get _categoryController {
    if (!Get.isRegistered<CategoryController>()) {
      Get.put(CategoryController(), permanent: true);
    }
    return Get.find<CategoryController>();
  }

  ProfileController get _profileController {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
    return Get.find<ProfileController>();
  }

  NetworkController get _networkController {
    if (!Get.isRegistered<NetworkController>()) Get.put(NetworkController());
    return Get.find<NetworkController>();
  }

  @override
  Color? get backgroundColor => AppColors.white;

  // `BaseView`'s default `SafeArea` reserves bottom padding matching the
  // floating bottom-nav bar's full height (Scaffold.extendBody feeds that
  // height into MediaQuery for body descendants), leaving an empty painted
  // strip behind the bar instead of real scrolled content. Bottom safe area
  // is handled manually below instead.
  @override
  bool get useSafeArea => false;

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

    return SafeArea(
      bottom: false,
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
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // ── Active announcement banner (dismissible) ──────────
                  Obx(
                    () => AnnouncementBanner(
                      announcement: controller.announcementDismissed.value
                          ? null
                          : controller.announcements.firstOrNull,
                      onDismiss: controller.dismissAnnouncement,
                    ),
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  const HomeSearchFilterRow(),
                  // ── Greeting ──────────────────────────────────────────
                  const HomeGreetingHeader(),

                  // ── Active marketing campaigns ─────────────────────────
                  CampaignsSection(),
                  SizedBox(height: BaseSpacing.xs),

                  // ── Platform trust stats ──────────────────────────────
                  PlatformStatsStrip(),

                  SizedBox(height: BaseSpacing.lg),
                  // ── Promotional banner ───────────────────────────────
                  isLoading ? BannerShimmer() : BannerCarousel(),

                  // ── Search + filter ───────────────────────────────────
                  SizedBox(height: BaseSpacing.lg),

                  // ── Browse by Category ───────────────────────────────
                  const HomeSectionHeader(title: 'Browse by Category'),
                  CategoriesGrid(),

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
                  HomeSectionHeader(
                    title: 'Trending near you',
                    viewMore: true,
                    onViewMore: () => Get.toNamed(Routes.trendingProducts),
                  ),

                  // SizedBox(height: BaseSpacing.sm),
                  isLoading
                      ? const DynamicShimmer()
                      : _ProductsSection(controller: controller),

                  SizedBox(height: BaseSpacing.lg),

                  // // ── Staff Picks ──────────────────────────────────────
                  // const HomeSectionHeader(title: 'Staff Picks'),

                  // const HomeStaffPicks(),

                  // SizedBox(height: BaseSpacing.lg),

                  // ── What buyers say ───────────────────────────────────
                  Obx(
                    () => controller.testimonials.isEmpty
                        ? const SizedBox.shrink()
                        : const HomeSectionHeader(title: 'What buyers say'),
                  ),
                  TestimonialsCarousel(),

                  SizedBox(height: BaseSpacing.lg),

                  // ── Free AI Worksheet Builder trial promo ─────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimen.allPadding,
                    ),
                    child: const WorksheetTrialPromoCard(),
                  ),

                  // ── "Sell on Solvexo" — guests only, deliberately below
                  // the fold so it never competes with the login banner ───
                  if (profileController.user.isNull) ...[
                    SizedBox(height: BaseSpacing.lg),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimen.allPadding,
                      ),
                      child: const SellOnSolvexoCard(),
                    ),
                  ],

                  // Lets the last card scroll fully clear of the floating
                  // nav bar instead of resting permanently tucked behind it.
                  SizedBox(height: WaveBottomNavBar.totalHeight),
                ],
              ),
            ),

            if (profileController.user.isNull)
              Positioned(
                left: BaseSpacing.sm,
                right: BaseSpacing.sm,
                bottom: BaseSpacing.sm,
                child: SafeArea(
                  child: LoginSignupCard(
                    onLoggedIn: profileController.refreshProfile,
                  ),
                ),
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

      final shown = controller.filteredProducts.length;
      final total = controller.totalProductsCount.value;

      return Column(
        children: [
          const ProductsGrid(),
          // SizedBox(height: BaseSpacing.md),
          if (total > 0)
            CustomText(
              text: 'Showing $shown of $total products',
              color: AppColors.gray600,
              fontSize: AppFontSize.tiny,
            ),
          SizedBox(height: BaseSpacing.sm),
          if (controller.hasMoreProducts.value)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimen.allPadding,
              ),
              child: OutlineButton(
                onPressed: isFetching ? null : controller.loadMoreProducts,
                isLoading: isFetching,
                label: 'Load More',
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                expand: false,
                compact: true,
              ),
            )
          else
            CustomText(
              text: "You've reached the end",
              color: AppColors.lightGrey7,
              fontSize: AppFontSize.tiny,
            ),
        ],
      );
    });
  }
}
