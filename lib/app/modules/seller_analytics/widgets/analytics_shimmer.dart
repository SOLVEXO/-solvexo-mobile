import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsShimmer extends StatelessWidget {
  const AnalyticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimen.allPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _revenueCardShimmer(),
            const SizedBox(height: 16),
            _statsGridShimmer(),
            const SizedBox(height: 16),
            _topProductsShimmer(),
          ],
        ),
      ),
    );
  }

  // ── Revenue card ─────────────────────────────────────────────────────────────
  Widget _revenueCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 13, width: 160),
          const SizedBox(height: 8),
          const Skeleton(height: 36, width: 180),
          const SizedBox(height: 8),
          const Skeleton(height: 12, width: 140),
          const SizedBox(height: 20),
          // Bar chart placeholders
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                7,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Skeleton(
                          height: [40.0, 60.0, 30.0, 70.0, 50.0, 55.0, 80.0][i],
                          width: double.infinity,
                          cornerRadius: 4,
                        ),
                        const SizedBox(height: 6),
                        const Skeleton(height: 10, width: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats grid ────────────────────────────────────────────────────────────────
  Widget _statsGridShimmer() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: List.generate(
        4,
        (_) => Container(
          padding: const EdgeInsets.all(AppDimen.allPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Skeleton(height: 11, width: 60),
              Skeleton(height: 28, width: 80),
              Skeleton(height: 10, width: 50),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top products ──────────────────────────────────────────────────────────────
  Widget _topProductsShimmer() {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 14, width: 100),
          const SizedBox(height: 14),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: const [
                  Skeleton(width: 44, height: 44, cornerRadius: 8),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(height: 13, width: double.infinity),
                        SizedBox(height: 6),
                        Skeleton(height: 10, width: 80),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Skeleton(height: 14, width: 55),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
