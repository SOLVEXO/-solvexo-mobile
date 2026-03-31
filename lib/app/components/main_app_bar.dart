import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/search/controllers/search_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String actionIcon;
  final double size;
  final Function()? onPressed;
  final bool issearch;
  const MainAppBar({
    super.key,
    this.size = AppFontSize.veryLarge3,
    this.actionIcon = AppIcons.heartIcon,
    this.onPressed,
    this.issearch = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchBarController());
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.only(
          top: Get.height / 15,
          bottom: AppDimen.borderRadius,
        ),
        decoration: BoxDecoration(gradient: AppColors.appbarGradient),
        child: Row(
          spacing: 10,
          children: [
            issearch
                ? Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: SvgIcon(
                      size: size,
                      assetName: AppIcons.chevronLeft,
                      onTap: () => Get.back(),
                    ),
                  )
                : SizedBox(),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.searchView),
                child: Container(
                  margin: const EdgeInsets.only(top: 10, left: 16),
                  // height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Obx(
                    () => CustomTextField(
                      controller: controller.textController,
                      onChanged: controller.onSearchChanged,
                      onFieldSubmitted: controller.performSearch,
                      suffixIcon: controller.searchText.isNotEmpty
                          ? GestureDetector(
                              onTap: controller.clearSearch,
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                            )
                          : null,
                      filled: false,
                      borderRadius: BorderRadius.circular(15),
                      prefixIcon: CustomIconButton(
                        onPressed: () => Get.toNamed(Routes.searchView),
                        assetName: AppIcons.searchIcon,
                        color: AppColors.lightGrey,
                      ),
                      // isborder: true,
                      borderBorderradius: 15,
                      hintText: "Search placeholder",
                    ),
                  ),
                ),
              ),
            ),
            // issearch ? SizedBox(width: 0) : Container(),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: issearch ? CartIconWithCount() : SizedBox(),
              // : CustomIconButton(
              //     assetName: actionIcon,
              //     size: size,
              //     onPressed: onPressed,
              //     color: AppColors.white,
              //   ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
