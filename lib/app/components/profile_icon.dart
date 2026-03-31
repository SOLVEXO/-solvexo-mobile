import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  final String iconName;
  const ProfileIcon({super.key, required this.iconName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(width: 4, color: AppColors.background),
        borderRadius: BorderRadius.circular(50),
      ),
      child: SvgIcon(
        assetName: iconName,
        color: AppColors.primaryColor,
        size: 22,
      ),
    );
  }
}
