import 'package:book_store_app/app/components/product_filter_bottom_sheet.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/home_search_bar.dart';
import 'package:book_store_app/app/modules/home/widgets/icon_badge.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Search bar + a filter trigger next to it — opens the same price/rating/
/// sort bottom sheet used on the Subcategory screen (see
/// `ProductFilterBottomSheet`), wired to `HomeController`'s filter state.
class HomeSearchFilterRow extends StatelessWidget {
  const HomeSearchFilterRow({super.key});

  void _showFilterSheet(BuildContext context) {
    final controller = Get.find<HomeController>();
    Get.bottomSheet(
      ProductFilterBottomSheet(
        minBound: HomeController.priceBoundMin,
        maxBound: HomeController.priceBoundMax,
        initialMinPrice: controller.currentMinFilter.value,
        initialMaxPrice: controller.currentMaxFilter.value,
        initialRating: controller.selectedRating.value,
        initialSort: controller.selectedSort.value,
        onApply: controller.applyFilters,
        onReset: controller.resetFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // `HomeSearchBar` already pads itself symmetrically to the screen edge,
    // so only the filter button needs an explicit right inset here — an
    // outer padding on this whole row would double up on the left.
    return HomeSearchBar(
      child: GestureDetector(
        onTap: () => _showFilterSheet(context),
        child: IconBadge(icon: AppIcons.filterIcon),
      ),
    );
  }
}
