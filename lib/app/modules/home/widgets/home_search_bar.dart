import 'package:book_store_app/app/components/app_search_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeSearchBar extends StatelessWidget {
  final Widget? child;
  const HomeSearchBar({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(
      () => AppSearchField(
        margin: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
        controller: controller.searchTextCtrl,
        onChanged: controller.searchProducts,
        staticHint: 'Search products…',
        rotatingHints: controller.categories.map((c) => c.name).toList(),
        suffixIcon: controller.searchQuery.value.isNotEmpty
            ? GestureDetector(
                onTap: controller.clearSearch,
                child: const SvgIcon(
                  assetName: AppIcons.cross,
                  color: AppColors.textPrimary,
                ),
              )
            : null,
        trailing: child,
      ),
    );
  }
}
