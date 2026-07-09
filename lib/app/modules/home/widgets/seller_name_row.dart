import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';

class SellerNameRow extends StatelessWidget {
  final String name;
  const SellerNameRow({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm - 2, vertical: BaseSpacing.xxs + 1),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(BaseRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: BaseSpacing.sm - 2,
        children: [
          CommonImageView(
            height: 20,
            width: 20,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(BaseRadius.pill),
          ),
          Text(name, style: BaseTypography.labelSmall(color: AppColors.gray600)),
        ],
      ),
    );
  }
}
