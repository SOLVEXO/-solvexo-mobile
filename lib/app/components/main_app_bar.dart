import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/search/controllers/search_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
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
        child: Column(
          spacing: 4,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimen.allPadding,
              ),
              child: Row(
                children: [
                  iconContainer(
                    child: Row(
                      spacing: 5,
                      children: [
                        CommonImageView(
                          imagePath: AppImages.logoImage,
                          width: 30,
                        ),
                        CustomText(
                          text: "Solvexo",
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: AppColors.acceptedBg,
                          fontSize: AppFontSize.medium,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(Routes.notifications),
                    child: iconContainer(
                      child: SvgIcon(assetName: AppIcons.notificationIcon),
                    ),
                  ),
                  SizedBox(width: 5),
                  iconContainer(child: CartIconWithCount()),
                ],
              ),
            ),
            issearch
                ? Row(
                    children: [
                      SizedBox(),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 5, left: 10),
                          // height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppDimen.borderRadius,
                            ),
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
                                        color: AppColors.black,
                                      ),
                                    )
                                  : null,
                              filled: false,
                              borderRadius: BorderRadius.circular(
                                AppDimen.borderRadius,
                              ),
                              prefixIcon: SvgIcon(
                                assetName: AppIcons.searchIcon,
                                color: AppColors.lightGrey,
                                size: 22,
                              ),
                              // isborder: true,
                              borderBorderradius: 15,
                              hintText: "Search ",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget iconContainer({Widget? child}) {
    return Container(
      // margin: EdgeInsets.only(right: 10.0, left: 10),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
      ),
      child: child,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
