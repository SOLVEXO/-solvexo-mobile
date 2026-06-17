import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _kSortOptions = [
  ('newest', 'Newest'),
  ('price_asc', 'Price ↑'),
  ('price_desc', 'Price ↓'),
  ('rating', 'Top Rated'),
];

class HomeSortChips extends StatelessWidget {
  const HomeSortChips({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    // Capture the observable value here, inside the Obx builder scope,
    // before passing to the lazy itemBuilder callback.
    return Obx(() {
      final currentSort = controller.selectedSort.value;

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
          itemCount: _kSortOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final (value, label) = _kSortOptions[i];
            final selected = currentSort == value;

            return GestureDetector(
              onTap: () => controller.changeSortOrder(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.lightGrey10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  text: label,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.gray600,
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
