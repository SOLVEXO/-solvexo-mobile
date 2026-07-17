import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StoresShimmer extends StatelessWidget {
  const StoresShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.md),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.lightGrey.withOpacity(0.5),
        highlightColor: AppColors.lightGrey.withOpacity(0.9),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(BaseRadius.md),
          ),
        ),
      ),
    );
  }
}
