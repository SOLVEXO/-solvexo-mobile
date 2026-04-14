import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/dynamic_shimmer.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/delivery_address.dart';
import 'package:book_store_app/app/components/main_app_bar.dart';
import 'package:book_store_app/app/components/no_signal_view.dart';
import 'package:book_store_app/app/data/services/network_controller.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/banner_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/categories_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/products_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/sub_category_grid.dart';
import 'package:book_store_app/app/modules/home/widgets/tab_header.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/modules/profile/widgets/login_signup_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // double w = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final controller = Get.put(HomeController());
    final profileController = Get.put(ProfileController());
    // final categoryController = Get.put(CategoryController());
    final networkController = Get.put(NetworkController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(),

      body: Obx(() {
        /// ❌ NO INTERNET
        if (!networkController.isConnected.value) {
          return const NoSignalView();
        }
        return Stack(
          children: [
            CustomRefreshWrapper(
              onRefresh: controller.refreshHome,
              child: Scrollbar(
                trackVisibility: true,
                interactive: true,
                thickness: 4,
                radius: const Radius.circular(10),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  children: [
                    DeliveryAddress(),

                    /// 🔹 Location bar UI space (you will put your own)
                    SizedBox(height: 15),

                    /// 🔹 Banner
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const DynamicShimmer(isbanner: true);
                      }
                      return BannerCarousel();
                    }),

                    SizedBox(height: 18),

                    /// 🔹 Categories - Now from backend
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const DynamicShimmer(iscategories: true);
                      }
                      // If categories are loading, show shimmer or placeholder
                      if (controller.categories.isEmpty) {
                        return SizedBox(
                          height: height / 3.25,
                          child: Center(
                            child: DynamicShimmer(iscategories: true),
                          ),
                        );
                      }
                      return CategoriesGrid();
                    }),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          //sub categories
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const DynamicShimmer(
                                issubcategories: true,
                              );
                            }
                            return SubCategoryGrid();
                          }),

                          SizedBox(height: 10),
                          Divider(thickness: 0.5),
                          SizedBox(height: 10),

                          /// 🔹 Tabs Header
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const DynamicShimmer(istabs: true);
                            }
                            return TabHeader();
                          }),

                          SizedBox(height: 5),

                          /// 🔹 Product grid - Now from backend with load more
                          Obx(() {
                            if (controller.isLoading.value) {
                              return const DynamicShimmer(isproducts: true);
                            }
                            // Show empty state if no products
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
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Obx(
                                        () => CustomText(
                                          text:
                                              'No ${controller.tabs[controller.tabIndex.value]} found',
                                          fontSize: 16,
                                          color: AppColors.gray600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                // Products Grid
                                ProductsGrid(),
                                SizedBox(height: 20),

                                // Load More Button - New addition for pagination
                                if (controller.hasMoreProducts.value &&
                                    !controller.isFetchingProducts.value)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: AppButton(
                                      onPressed: controller.loadMoreProducts,
                                      label: 'Load More Products',
                                    ),
                                  ),

                                // Loading Indicator when fetching more
                                if (controller.isFetchingProducts.value)
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Obx(() {
              if (profileController.user.value.isNull) {
                return Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: SafeArea(child: LoginSignupCard()),
                );
              }
              return const SizedBox();
            }),
          ],
        );
      }),
    );
  }
}
