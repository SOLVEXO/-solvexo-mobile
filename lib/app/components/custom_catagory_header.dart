import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';

class CustomCatagoryHeader extends StatelessWidget {
  final String productImage;
  const CustomCatagoryHeader({super.key, required this.productImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        color: AppColors.primaryColor.withOpacity(0.2),
        boxShadow: BaseShadows.forLevel(BaseElevation.level2),
      ),
      child: CommonImageView(
        url: productImage,
        fit: BoxFit.cover,
        radius: BorderRadius.circular(BaseRadius.lg),
      ),
    );
  }
}
