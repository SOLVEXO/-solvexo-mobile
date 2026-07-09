import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Products-grid loading placeholder — mirrors `ProductsGrid`'s 2-column
/// layout so there's no visual jump when real data replaces it.
class DynamicShimmer extends StatelessWidget {
  const DynamicShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.textPrimary.withOpacity(.2),
      highlightColor: AppColors.background,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: .9,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(.1),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
