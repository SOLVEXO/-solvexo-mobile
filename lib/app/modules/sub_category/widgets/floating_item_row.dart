import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/sub_category/controller/sub_category_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomFloatingButton extends StatelessWidget {
  CustomFloatingButton({super.key});
  final controller = Get.find<SubCategoryController>();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.xxl),
        boxShadow: BaseShadows.forLevel(BaseElevation.level2),
      ),
      height: h / 12,
      width: w / 2,
      child: Row(
        children: [
          Expanded(child: customRow(AppIcons.filterIcon, "Filters", context)),
          VerticalDivider(color: AppColors.lightGrey, thickness: 0.5, indent: BaseSpacing.xl, endIndent: BaseSpacing.xl),
          Expanded(child: customRow(AppIcons.sortIcon, "Sort", context)),
        ],
      ),
    );
  }

  // NOTE: "Sort" opens the same filter bottom sheet as "Filters" — there is
  // no separate sort controller method (`SubCategoryController` only has
  // `openFilterBottomSheet()`). Left as-is rather than inventing sort
  // behavior (by price/rating/newest?) that wasn't specified; flagging for
  // a product decision on what "Sort" should actually do.
  Widget customRow(String icon, String text, context) {
    return GestureDetector(
      onTap: () => controller.openFilterBottomSheet(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: BaseSpacing.xs,
        children: [
          SvgIcon(assetName: icon, color: AppColors.black),
          Text(text, style: BaseTypography.bodyMedium(color: AppColors.black)),
        ],
      ),
    );
  }
}
