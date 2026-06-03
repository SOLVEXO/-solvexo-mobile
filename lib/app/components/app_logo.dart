// ignore_for_file: deprecated_member_use

import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:flutter/material.dart';
// import 'package:hifzpro_app/apptheme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double? size;

  const AppLogo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final logoSize = size ?? (isTablet ? 160.0 : 80.0);

    return Container(
      height: logoSize,
      width: logoSize,
      decoration: BoxDecoration(
        color: AppColors.white, // White circular background
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 15),
      child: SvgIcon(assetName: AppImages.logoImage),
    );
  }
}
