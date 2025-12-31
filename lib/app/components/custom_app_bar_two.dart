import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBarTwo extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? child;
  final Color color;
  final bool centerTitle;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? iconColor;
  final double appbarHeight;
  final String assetName;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const CustomAppBarTwo({
    super.key,
    this.title,
    this.color = AppColors.black,
    this.centerTitle = false,
    this.showBackButton = true,
    this.backgroundColor,
    this.iconColor,
    this.actions,
    this.onBack,
    this.appbarHeight = 60.0,
    this.child,
    this.assetName = AppIcons.home,
  });

  @override
  Size get preferredSize => Size.fromHeight(appbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.white,
      centerTitle: centerTitle,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              onPressed: onBack ?? () => Get.back(),
              icon: Icon(
                Icons.chevron_left,
                size: isTablet ? 50 : 35,
                color: color,
              ),
            )
          : IconButton(
              onPressed: onBack ?? () => Get.back(),
              icon: SvgIcon(
                assetName: assetName,
                size: isTablet ? 50 : 35,
                color: color,
              ),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title ?? "",
            color: color,
            fontSize: isTablet ? 24 : AppFontSize.medium,
            fontWeight: FontWeight.w600,
          ),
          Container(child: child),
        ],
      ),
      actions: actions,
    );
  }
}
