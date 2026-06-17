import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class RattingRow extends StatelessWidget {
  const RattingRow({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 5 stars — use tiny size so they never overflow on narrow cards
        ...List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 2.0),
            child: SvgIcon(
              assetName: index < product.averageRating.floor()
                  ? AppIcons.fillStar
                  : AppIcons.starOutlined,
              size: AppFontSize.tiny, // 12px — was 16px which overflowed
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Flexible so the count label shrinks/ellipses instead of overflowing
        Flexible(
          child: CustomText(
            text: product.totalRatings > 0
                ? '(${product.totalRatings})'
                : 'No reviews',
            fontSize: AppFontSize.tiny,
            color: AppColors.greyDefault,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
