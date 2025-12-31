import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class ButtonWithIcon extends StatelessWidget {
  final String label;
  final String iconName;
  final Function()? onTap;
  const ButtonWithIcon({
    super.key,
    required this.label,
    required this.iconName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            CustomText(text: label, fontWeight: FontWeight.w500),
            SizedBox(width: 10),
            SvgIcon(assetName: iconName, color: AppColors.classBg),
          ],
        ),
      ),
    );
  }
}
