import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SellerOrderDetailShimmer extends StatelessWidget {
  const SellerOrderDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimen.allPadding),
        child: Column(
          children: [
            _statusCard(),
            const SizedBox(height: 12),
            _infoCard(rows: 2),
            const SizedBox(height: 12),
            _itemsCard(),
            const SizedBox(height: 12),
            _infoCard(rows: 2),
            const SizedBox(height: 12),
            _infoCard(rows: 2),
            const SizedBox(height: 20),
            _button(),
            const SizedBox(height: 12),
            _button(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    return _card(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          const Skeleton(height: 22, width: 90, cornerRadius: 12),
          const SizedBox(height: 8),
          const Skeleton(height: 13, width: 120),
          const SizedBox(height: 5),
          const Skeleton(height: 11, width: 90),
        ],
      ),
    );
  }

  Widget _infoCard({required int rows}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + title
          const Row(
            children: [
              Skeleton(width: 16, height: 16, cornerRadius: 4),
              SizedBox(width: 8),
              Skeleton(height: 13, width: 80),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.white),
          const SizedBox(height: 12),
          for (int i = 0; i < rows; i++) ...[
            Row(
              children: const [
                Skeleton(height: 11, width: 70),
                SizedBox(width: 16),
                Skeleton(height: 11, width: 120),
              ],
            ),
            if (i < rows - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _itemsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Skeleton(width: 16, height: 16, cornerRadius: 4),
              SizedBox(width: 8),
              Skeleton(height: 13, width: 70),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.white),
          const SizedBox(height: 12),
          for (int i = 0; i < 2; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Skeleton(height: 12, width: double.infinity),
                      SizedBox(height: 5),
                      Skeleton(height: 18, width: 60, cornerRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Skeleton(height: 10, width: 24),
                    SizedBox(height: 5),
                    Skeleton(height: 12, width: 50),
                  ],
                ),
              ],
            ),
            if (i < 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.white),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Skeleton(height: 12, width: 40),
              Skeleton(height: 14, width: 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.borderRadius),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      ),
      child: child,
    );
  }
}
