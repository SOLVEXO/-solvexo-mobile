import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackButton extends StatelessWidget {
  final Widget? icon;
  const BackButton({
    super.key,
    this.icon = const Icon(
      Icons.chevron_left,
      size: 35,
      color: AppColors.white,
    ),
  });

  @override
  Widget build(BuildContext context) {
    // final isTablet = MediaQuery.of(context).size.width >= 600;
    return IconButton(
      onPressed: () {
        Get.back();
      },
      icon: icon!,
      color: AppColors.bgColorSearchField,
    );
  }
}
