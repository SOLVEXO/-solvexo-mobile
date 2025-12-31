// ignore_for_file: deprecated_member_use

import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
// import 'package:hifzpro_app/apptheme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Widget? iconWidget;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    final btnColor =
        backgroundColor ??
        (isOutlined ? Colors.transparent : AppColors.primaryColor);

    final borderColor = backgroundColor;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon:
            iconWidget ??
            (icon != null
                ? Icon(
                    icon,
                    color: textColor ?? Colors.white,
                    size: isTablet ? 24 : 20,
                  )
                : const SizedBox()),
        label: CustomText(
          // fontFamily: AppTextStyles.fontFamily,
          text: label,
          color: textColor ?? (isOutlined ? AppColors.white : Colors.white),
          fontSize: isTablet ? 20 : 16,
          fontWeight: FontWeight.w600,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isOutlined
                  ? borderColor ?? AppColors.primaryColor
                  : AppColors.transparent,
              width: 1.4,
            ),
          ),
          elevation: isOutlined ? 0 : 2,
        ),
      ),
    );
  }
}
