import 'package:book_store_app/app/base_view/base_view_screen.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/horizontal_product_card.dart';
import 'package:book_store_app/app/modules/search/controllers/search_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final c = Get.put(SearchBarController());
  final productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return BaseViewScreen(
      backgroundColor: AppColors.white,
      safeAreaTop: true,
      showCustomAppBar: true,
      height: 120,
      mainAppBar: true,
      issearch: true,
      verticalPadding: false,
      showBottomBar: false,
      bottomBarShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No Results Message
          Obx(
            () => c.showResults.value && !c.loading.value && !c.hasResults
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                    child: Center(
                      child: Column(
                        spacing: 10,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: AppColors.shimmerBase,
                          ),
                          CustomText(
                            text: "No Products Found",
                            fontSize: AppFontSize.medium,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                          CustomText(
                            text:
                                "Try different keywords or check our recommendations",
                            fontSize: AppFontSize.small2,
                            textAlign: TextAlign.center,
                            color: AppColors.gray600,
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
          ),

          // Recent Searches Header
          Obx(
            () => c.searchText.value.isEmpty && !c.showResults.value
                ? _recentHeader()
                : SizedBox(),
          ),

          // Recent Searches List OR Suggestions
          Obx(() {
            if (c.searchText.value.isEmpty && !c.showResults.value) {
              return _recentSearchList();
            }

            if (c.showSuggestions.value && c.suggestions.isNotEmpty) {
              return suggestionList();
            }

            return const SizedBox();
          }),

          const SizedBox(height: 5),

          // See More/Less Button for Recent Searches
          Obx(
            () => c.searchText.value.isEmpty && !c.showResults.value
                ? _seeMoreButton()
                : SizedBox(),
          ),

          const SizedBox(height: 20),

          // Section Header (Products/Last Seen/Recommended)
          Obx(() {
            if (c.showResults.value && c.hasResults) {
              return _sectionHeader("Search Results (${c.resultsCount})");
            } else if (c.searchText.value.isEmpty) {
              return _sectionHeader("Recently Viewed");
            } else if (c.showSuggestions.value && !c.hasResults) {
              return _sectionHeader("Recommended Products");
            }
            return SizedBox();
          }),

          const SizedBox(height: 10),

          // Main Content Area
          Obx(() {
            if (c.showResults.value) {
              return Expanded(child: _resultsBody());
            } else if (c.searchText.value.isEmpty) {
              return _lastSeenList(w);
            } else if (c.showSuggestions.value) {
              return RecommendedProductList();
            }
            return SizedBox();
          }),
        ],
      ),
    );
  }

  /// Results body with backend products
  Widget _resultsBody() {
    return Obx(
      () => c.loading.value
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: CircularProgressIndicator(),
              ),
            )
          : ListView.builder(
              itemCount: c.filteredProducts.length,
              itemBuilder: (_, i) {
                final prod = c.filteredProducts[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HorizontalProductCard(
                    prod: prod,
                    onTap: () {
                      productController.openProductDetails(
                        c.filteredProducts[i],
                      );
                      // Navigate to product details
                      // Get.toNamed(Routes.PRODUCT_DETAILS, arguments: prod);

                      // Add to recently viewed
                      c.addToRecentlyViewed(prod.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  /// Recent searches header
  Widget _recentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CustomText(
          text: "Recent Searches",
          fontWeight: FontWeight.bold,
          fontSize: AppFontSize.regular,
        ),
        if (c.recentSearches.isNotEmpty)
          TextButton(
            onPressed: c.clearRecentSearches,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: AppFontSize.small,
              ),
            ),
          ),
      ],
    );
  }

  /// Recent searches list
  Widget _recentSearchList() {
    if (c.recentSearches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CustomText(
            text: "No recent searches",
            color: AppColors.gray600,
            fontSize: AppFontSize.small,
          ),
        ),
      );
    }

    return Column(
      children: c.shownRecentSearches.map((item) {
        return InkWell(
          onTap: () {
            c.textController.text = item;
            c.performSearch(item);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: AppColors.gray600),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    text: item,
                    fontSize: AppFontSize.small,
                    color: AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => c.deleteRecent(item),
                  child: Icon(
                    Icons.close,
                    size: 25,
                    color: AppColors.greyDefault,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// See more/less button
  Widget _seeMoreButton() {
    return Obx(
      () => c.recentSearches.length > 4
          ? AppButton(
              isOutlined: true,
              // textColor: AppColors.primaryColor,
              label: c.showAll.value ? "See less" : "See more",
              onPressed: () => c.toggleSeeMore(),
            )
          : const SizedBox(),
    );
  }

  /// Section header
  Widget _sectionHeader(String text) {
    return CustomText(
      text: text,
      fontWeight: FontWeight.bold,
      fontSize: AppFontSize.regular,
    );
  }

  /// Last seen/recently viewed list
  Widget _lastSeenList(double w) {
    if (c.lastSeenProducts.isEmpty) {
      // Fallback to dummy images
      return SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: c.lastSeenImages.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, index) {
            final item = c.lastSeenImages[index];
            return Container(
              width: w / 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.shimmerHighlight,
              ),
              child: CommonImageView(
                imagePath: item,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      );
    }

    // Real backend products
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: c.lastSeenProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final product = c.lastSeenProducts[index];
          return GestureDetector(
            onTap: () {
              // Navigate to product details
              // Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product);
            },
            child: Container(
              width: w / 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.shimmerHighlight,
              ),
              child: CommonImageView(
                url: product.images.isNotEmpty ? product.images.first : null,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Suggestions list
  Widget suggestionList() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: AppColors.black.withOpacity(0.1)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: c.suggestions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.background, thickness: 1),
        itemBuilder: (_, i) {
          final item = c.suggestions[i];
          return InkWell(
            onTap: () => c.selectSuggestion(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Row(
                children: [
                  SvgIcon(assetName: AppIcons.searchIcon, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: item.name,
                          fontSize: AppFontSize.small,
                          color: AppColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        if (item.category != null) ...[
                          SizedBox(height: 2),
                          CustomText(
                            text: item.category!.name,
                            fontSize: AppFontSize.verySmall,
                            color: AppColors.gray600,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.north_west,
                    size: 20,
                    color: AppColors.greySwatch400,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
