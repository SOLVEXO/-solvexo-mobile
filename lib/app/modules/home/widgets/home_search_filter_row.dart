import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/widgets/home_search_bar.dart';
import 'package:book_store_app/app/modules/home/widgets/home_sort_chips.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Search bar + a filter trigger next to it — the sort options that used to
/// sit inline as a chip row now live in a bottom sheet behind this button,
/// keeping the same sorting feature but out of the way visually.
class HomeSearchFilterRow extends StatelessWidget {
  const HomeSearchFilterRow({super.key});

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          BaseSpacing.md,
          BaseSpacing.sm,
          BaseSpacing.md,
          BaseSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: EdgeInsets.only(bottom: BaseSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            CustomText(
              text: 'Sort by',
              color: AppColors.black2,
              fontSize: AppFontSize.extraSmall,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: BaseSpacing.sm),
            const HomeSortChips(),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
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
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: SvgIcon(
            assetName: AppIcons.filterIcon,
            color: AppColors.white,
            size: 27,
          ),
        ),
      ),
    );
  }
}
