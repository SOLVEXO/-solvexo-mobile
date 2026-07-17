import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// Bold section heading used throughout the product details screen
/// ("Color", "Size", "Description", "Reviews", "Related Products").
class ProductSectionTitle extends StatelessWidget {
  final String text;
  final Color color;

  const ProductSectionTitle(this.text, {super.key, this.color = AppColors.black});

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: text,
      color: color,
      fontSize: AppFontSize.small2,
      fontWeight: FontWeight.w800,
    );
  }
}
