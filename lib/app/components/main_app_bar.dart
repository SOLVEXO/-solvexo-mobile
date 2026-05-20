import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/search/controllers/search_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String actionIcon;
  final double size;
  final Function()? onPressed;
  final bool issearch;
  final double height;
  const MainAppBar({
    super.key,
    this.size = 22,
    this.actionIcon = AppIcons.heartIcon,
    this.onPressed,
    this.height = 80,
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
          children: [
            issearch
                ? Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                          AppDimen.borderRadius,
                        ),
                      ),
                      child: SvgIcon(
                        size: size,
                        assetName: AppIcons.chevronLeft,
                        onTap: () => Get.back(),
                      ),
                    ),
                  )
                : SizedBox(),
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(Routes.searchView),
                child: Container(
                  margin: const EdgeInsets.only(top: 5, left: 10),
                  // height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimen.borderRadius),
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
                      borderRadius: BorderRadius.circular(
                        AppDimen.borderRadius,
                      ),
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
            issearch
                ? Container(
                    margin: EdgeInsets.only(right: 10.0, left: 10),
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(
                        AppDimen.borderRadius,
                      ),
                    ),
                    child: CartIconWithCount(),
                  )
                : SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
