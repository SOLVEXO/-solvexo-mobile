import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final Color color;
  final String label;
  final String icon;
  final Color? iconColor;
  final Color? textColor;
  final Function() onPressed;

  const SocialButton({
    super.key,
    required this.color,
    required this.label,
    required this.icon,
    this.iconColor,
    this.textColor,
    required this.onPressed,
  });

  factory SocialButton.google(Function() onPressed) => SocialButton(
    color: Colors.white,
    textColor: AppColors.textPrimary,
    label: "Continue with Google",
    icon: AppIcons.googleIcon,
    onPressed: onPressed,
  );

  factory SocialButton.facebook(Function() onPressed) => SocialButton(
    color: Color(0xFF1877F2),
    label: "Continue with Facebook",
    icon: AppIcons.facebookIcon,
    onPressed: onPressed,
  );

  factory SocialButton.apple(Function() onPressed) => SocialButton(
    color: Colors.black,
    label: "Continue with Apple",
    icon: AppIcons.appleIcon,
    iconColor: AppColors.white,
    onPressed: onPressed,
  );

  @override
  Widget build(BuildContext context) {
    return AppButton(
      textColor: textColor,
      backgroundColor: color,
      label: label,
      onPressed: onPressed,
      iconWidget: SvgIcon(assetName: icon, color: iconColor),
    );
  }
}
