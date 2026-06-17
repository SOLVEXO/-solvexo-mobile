import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: CustomTextField(
        isborder: true,
        fillColor: AppColors.textfldFillColor,
        // filled: true,
        controller: controller.searchTextCtrl,
        onChanged: controller.searchProducts,
        hintText: 'Search products…',
        borderBorderradius: AppDimen.borderRadius,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(5),
          child: SvgIcon(
            assetName: AppIcons.searchIcon,
            size: 20,
            color: AppColors.iosGrey,
          ),
        ),
        suffixIcon: Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? GestureDetector(
                  onTap: controller.clearSearch,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SvgIcon(
                      assetName: AppIcons.cross,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              : const SizedBox(width: 12),
        ),
      ),
    );
  }
}
