import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
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
            padding: EdgeInsets.only(right: BaseSpacing.xxs / 2),
            child: SvgIcon(
              assetName: index < product.averageRating.floor()
                  ? AppIcons.fillStar
                  : AppIcons.starOutlined,
              size: 12, // was 16px which overflowed
            ),
          ),
        ),
        SizedBox(width: BaseSpacing.xxs),
        // Flexible so the count label shrinks/ellipses instead of overflowing
        Flexible(
          child: Text(
            product.totalRatings > 0 ? '(${product.totalRatings})' : 'No reviews',
            style: BaseTypography.labelSmall(color: AppColors.greyDefault).copyWith(fontWeight: FontWeight.w400),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
