import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class IconWithText extends StatelessWidget {
  final String iconName, text;
  final Function()? onTap;
  const IconWithText({
    super.key,
    this.onTap,
    required this.iconName,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        spacing: 2,
        children: [
          SvgIcon(assetName: iconName, size: 25),
          CustomText(
            text: text,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
