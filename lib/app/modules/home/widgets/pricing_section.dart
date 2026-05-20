import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class PricingSection extends StatelessWidget {
  const PricingSection({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Current Price (or Discounted Price)
        CustomText(
          text: "\$${product.price.toStringAsFixed(2)}",
          fontSize: AppFontSize.regular,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),

        const SizedBox(width: 8),

        // Original Price (if discounted)
        // if (product.)
        //   CustomText(
        //     text: "\$${product.price.toStringAsFixed(2)}",
        //     fontSize: AppFontSize.small,
        //     fontWeight: FontWeight.w500,
        //     color: Colors.grey,
        //     textDecoration: TextDecoration.lineThrough,
        //   ),
      ],
    );
  }
}
