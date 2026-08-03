import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Current price (discount price support: TODO once the backend
        // model exposes an original/discounted price pair — not present on
        // ProductModel yet, so a strikethrough original price can't be
        // rendered correctly here without guessing at data that isn't there).
        CustomText(
          text: "\$${product.price.toStringAsFixed(2)}",
          color: AppColors.primaryColor,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.w700,
          fontFamily: AppTextStyles.monoFontFamily,
        ),
        SizedBox(width: BaseSpacing.xs),
      ],
    );
  }
}
