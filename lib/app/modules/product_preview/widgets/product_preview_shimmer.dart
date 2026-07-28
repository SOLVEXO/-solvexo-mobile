import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductPreviewShimmer extends StatelessWidget {
  const ProductPreviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      period: const Duration(milliseconds: 1400),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: AppColors.shimmerShapeAlt,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
