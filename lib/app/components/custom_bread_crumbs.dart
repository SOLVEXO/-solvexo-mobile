import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBreadCrumbs extends StatelessWidget {
  final String categoryName;

  const CustomBreadCrumbs({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgIcon(assetName: AppIcons.home, size: AppFontSize.verySmall),

        const SizedBox(width: 6),

        GestureDetector(
          onTap: () => Get.back(),
          child: const CustomText(
            text: "Home",
            fontSize: AppFontSize.verySmall,
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right, size: 17, color: Colors.black54),
        ),

        CustomText(
          text: categoryName,
          fontSize: AppFontSize.verySmall,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
