import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductsShimmer extends StatelessWidget {
  const ProductsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        itemCount: 5,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(AppDimen.borderRadius + 4),
            ),
          ),
          const SizedBox(width: 12),
          // Info placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(height: 14, width: double.infinity),
                SizedBox(height: 7),
                Row(
                  children: [
                    Skeleton(height: 13, width: 50),
                    SizedBox(width: 6),
                    Skeleton(height: 20, width: 55, cornerRadius: 8),
                    SizedBox(width: 6),
                    Skeleton(height: 20, width: 65, cornerRadius: 8),
                  ],
                ),
                SizedBox(height: 7),
                Skeleton(height: 11, width: 130),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Edit button placeholder
          const Skeleton(height: 34, width: 52, cornerRadius: 8),
        ],
      ),
    );
  }
}
