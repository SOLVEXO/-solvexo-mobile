import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "★ 4.8 (23) | 120 Sold" row.
class ProductRatingSoldRow extends StatelessWidget {
  final ProductDetailController controller;
  final ProductModel product;

  const ProductRatingSoldRow({
    super.key,
    required this.controller,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: BaseSpacing.xxs + 1,
      children: [
        SvgIcon(assetName: AppIcons.fillStar, size: 16),
        CustomText(
          text: product.averageRating.toStringAsFixed(1),
          color: AppColors.black,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w600,
        ),
        Obx(
          () => CustomText(
            text: '(${controller.reviewStats.value.totalReviews})',
            color: AppColors.gray600,
            fontSize: AppFontSize.tiny,
          ),
        ),
        const VerticalDivider(color: AppColors.black, width: 1, thickness: 2),
        CustomText(
          text: '${product.purchaseCount} Sold',
          color: AppColors.black,
          fontSize: AppFontSize.tiny,
        ),
      ],
    );
  }
}
