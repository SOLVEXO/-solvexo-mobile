import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/card_shimmer.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/main_app_bar.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/widgets/horizontal_product_card.dart';
import 'package:book_store_app/app/modules/search/controllers/search_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchView extends StatelessWidget {
  SearchView({super.key});

  final c = Get.put(SearchBarController());

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: appBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => c.showResults.value
                  ? SizedBox()
                  : c.showSuggestions.value
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 30,
                      ),
                      child: Center(
                        child: Column(
                          spacing: 10,
                          children: [
                            CustomText(
                              text: "Sorry, Product is not Found",
                              fontSize: AppFontSize.medium,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.center,
                            ),
                            CustomText(
                              text:
                                  "Find other Products or check our recommendation Product",
                              fontSize: AppFontSize.small2,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
            Obx(
              () => c.searchText.value.isEmpty ? _recentHeader() : SizedBox(),
            ),
            Obx(() {
              if (c.searchText.value.isEmpty) {
                return _recentSearchList();
              }

              if (!c.showSuggestions.value || c.suggestions.isEmpty) {
                return const SizedBox();
              }

              return suggetionList();
            }),
            const SizedBox(height: 5),
            Obx(
              () => c.searchText.value.isEmpty ? _seeMoreButton() : SizedBox(),
            ),
            const SizedBox(height: 20),
            Obx(
              () => _lastSeenHeader(
                c.showResults.value
                    ? "Product"
                    : c.searchText.value.isEmpty
                    ? "Last Seen"
                    : "Recomanded Product",
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => c.showResults.value
                  ? Expanded(child: _resultsBody())
                  : c.searchText.value.isEmpty
                  ? _lastSeenList(w)
                  : RecommendedProductList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsBody() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Shimmer when loading
          c.loading.value
              ? const SizedBox(height: 100, child: CardShimmer())
              : Expanded(
                  child: ListView.builder(
                    itemCount: c.filteredProducts.length,
                    itemBuilder: (_, i) {
                      final prod = c.filteredProducts[i];
                      return HorizontalProductCard(
                        prodName: prod.name,
                        prodDesc: prod.description,
                        price: prod.price.toString(),
                        reviews: prod.reviews.toString(),
                        ratings: prod.rating,
                        prodImage: prod.image,
                        index: i,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, left: 10),
          child: CustomIconButton(
            assetName: AppIcons.chevronLeft,
            size: 30,
            onPressed: () => Get.back(),
          ),
        ),
        Expanded(
          child: MainAppBar(
            actionIcon: AppIcons.cartIcon,
            onPressed: () => Get.toNamed(Routes.cartView),
          ),
        ),
      ],
    );
  }

  Widget _recentHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: CustomText(
        text: "Recent Searches",
        fontWeight: FontWeight.bold,
        fontSize: AppFontSize.regular,
      ),
    );
  }

  Widget _recentSearchList() {
    return Column(
      children: c.shownRecentSearches.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.gray600),
              const SizedBox(width: 10),
              Expanded(
                child: CustomText(
                  text: item,
                  fontSize: AppFontSize.small,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => c.deleteRecent(item),
                child: const Icon(Icons.close, size: 25),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _seeMoreButton() {
    return Obx(
      () => c.recentSearches.length > 4
          ? AppButton(
              isOutlined: true,
              textColor: AppColors.primaryColor,
              label: c.showAll.value ? "See less" : "See more",
              onPressed: () => c.toggleSeeMore(),
            )
          : const SizedBox(),
    );
  }

  Widget _lastSeenHeader(String text) {
    return CustomText(
      text: text,
      fontWeight: FontWeight.bold,
      fontSize: AppFontSize.regular,
    );
  }

  Widget _lastSeenList(double w) {
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
              color: const Color(0xffF5F5F5),
            ),
            child: SvgIcon(assetName: item),
          );
        },
      ),
    );
  }

  Widget suggetionList() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: c.suggestions.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.background, thickness: 3),
        itemBuilder: (_, i) {
          final item = c.suggestions[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                SvgIcon(assetName: AppIcons.searchIcon),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomText(
                    text: item.name,
                    fontSize: AppFontSize.small,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => c.selectSuggestion(item),
                  child: const Icon(Icons.trending_up_rounded, size: 25),
                ),
              ],
            ),
          );
          // return ListTile(
          //   leading: const Icon(Icons.search),
          //   title: Text(item.name),
          //   subtitle: Text(item.description),
          //   onTap: () => c.selectSuggestion(item),
          // );
        },
      ),
    );
  }
}
