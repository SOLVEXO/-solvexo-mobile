import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
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
          separatorBuilder: (_, __) => SizedBox(width: BaseSpacing.xs),
          itemBuilder: (_, i) {
            final (value, label) = _kSortOptions[i];
            final selected = currentSort == value;

            return GestureDetector(
              onTap: () => controller.changeSortOrder(value),
              child: AnimatedContainer(
                duration: BaseMotion.normal,
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.xs),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryColor : AppColors.lightGrey10,
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: BaseTypography.labelSmall(
                    color: selected ? AppColors.white : AppColors.gray600,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
