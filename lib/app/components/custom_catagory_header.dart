import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class CustomCatagoryHeader extends StatelessWidget {
  final String title;
  final String desc;
  final String productImage;
  const CustomCatagoryHeader({
    super.key,
    required this.title,
    required this.desc,
    required this.productImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.primaryColor.withOpacity(0.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 7,
              children: [
                CustomText(
                  textAlign: TextAlign.center,
                  text: title,
                  fontSize: AppFontSize.medium,
                  fontWeight: FontWeight.w600,
                ),
                CustomText(
                  textAlign: TextAlign.center,
                  text: desc,
                  fontSize: AppFontSize.small,
                ),
              ],
            ),
          ),
          SvgIcon(assetName: productImage, size: 210),
        ],
      ),
    );
  }
}
