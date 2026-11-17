import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SellerActivityLogShimmer extends StatelessWidget {
  const SellerActivityLogShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimen.allPadding),
        children: [
          _statsGridShimmer(),
          const SizedBox(height: 16),
          Row(
            children: List.generate(4, (i) {
              final widths = [40.0, 70.0, 60.0, 80.0];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Skeleton(height: 32, width: widths[i], cornerRadius: 20),
              );
            }),
          ),
          const SizedBox(height: 16),
          ...List.generate(6, (_) => activityLogTileShimmer()),
        ],
      ),
    );
  }

  Widget _statsGridShimmer() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCardShimmer()),
            const SizedBox(width: 10),
            Expanded(child: _statCardShimmer()),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _statCardShimmer()),
            const SizedBox(width: 10),
            Expanded(child: _statCardShimmer()),
          ],
        ),
      ],
    );
  }

  Widget _statCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Skeleton(width: 29, height: 29, cornerRadius: 9),
          const SizedBox(height: 14),
          const Skeleton(height: 22, width: 50),
          const SizedBox(height: 5),
          const Skeleton(height: 11, width: 70),
        ],
      ),
    );
  }

}

/// A single skeleton row matching [ActivityLogTile]'s layout. Shared by the
/// full-page [SellerActivityLogShimmer] and [ActivityLogListShimmer] (used
/// for in-place reloads / the infinite-scroll "load more" footer) so both
/// states look identical while data streams in.
Widget activityLogTileShimmer() {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14)),
    child: Row(
      children: [
        Skeleton(width: 40, height: 40, cornerRadius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Skeleton(height: 13, width: double.infinity),
              SizedBox(height: 6),
              Skeleton(height: 11, width: 120),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Skeleton(height: 11, width: 40),
      ],
    ),
  );
}

/// Standalone tile-row shimmer (own [Shimmer.fromColors] wrapper) for
/// contexts where only the list portion reloads — e.g. a filter/search
/// change, or the infinite-scroll "load more" footer — while the stats
/// header and filter bar above stay on screen.
class ActivityLogListShimmer extends StatelessWidget {
  final int itemCount;
  const ActivityLogListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        children: List.generate(itemCount, (_) => activityLogTileShimmer()),
      ),
    );
  }
}
