import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrdersShimmer extends StatelessWidget {
  const OrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimen.allPadding),
        itemCount: 4,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Skeleton(height: 14, width: 60),
              Skeleton(height: 24, width: 80, cornerRadius: 20),
            ],
          ),
          const SizedBox(height: 10),
          const Skeleton(height: 14, width: double.infinity),
          const SizedBox(height: 8),
          Row(
            children: const [
              Skeleton(height: 12, width: 80),
              SizedBox(width: 6),
              Skeleton(height: 20, width: 55, cornerRadius: 8),
              Spacer(),
              Skeleton(height: 14, width: 50),
            ],
          ),
          const SizedBox(height: 6),
          const Skeleton(height: 11, width: 80),
        ],
      ),
    );
  }
}
