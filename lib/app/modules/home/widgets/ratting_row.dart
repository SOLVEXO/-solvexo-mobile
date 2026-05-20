import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class RattingRow extends StatelessWidget {
  const RattingRow({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Star Icons
        ...List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: SvgIcon(
              assetName: index < product.totalRatings.floor()
                  ? AppIcons.fillStar
                  : AppIcons.starOutlined,
              size: AppFontSize.small,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Rating Count
        CustomText(
          text: "(${product.totalRatings})",
          fontSize: AppFontSize.small,
          color: Colors.grey,
        ),
      ],
    );
  }
}
