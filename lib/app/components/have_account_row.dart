import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class HaveAccountRow extends StatelessWidget {
  final String text;
  final String buttonName;
  final Function()? onPressed;
  const HaveAccountRow({
    super.key,
    required this.text,
    required this.buttonName,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomText(
          text: text,
          color: AppColors.white,
          fontSize: AppFontSize.small2,
        ),
        TextButton(
          onPressed: onPressed,
          child: CustomText(
            text: buttonName,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.small,
          ),
        ),
      ],
    );
  }
}
