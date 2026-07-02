import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FinanceShimmer extends StatelessWidget {
  const FinanceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 30),
        children: [
          _balanceCardShimmer(),
          const SizedBox(height: 12),
          _statsGridShimmer(),
          const SizedBox(height: 12),
          _transactionListShimmer(),
          const SizedBox(height: 12),
          _sectionCardShimmer(rows: 4, hasButton: true),
          const SizedBox(height: 12),
          _sectionCardShimmer(rows: 5, hasButton: false),
          const SizedBox(height: 12),
          _taxReportsShimmer(),
        ],
      ),
    );
  }

  // ── Balance card ─────────────────────────────────────────────────────────────

  Widget _balanceCardShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Skeleton(height: 13, width: 120),
              Skeleton(height: 24, width: 68, cornerRadius: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Skeleton(height: 34, width: 160),
          const SizedBox(height: 20),
          Row(
            children: [
              _metaChipShimmer(),
              const SizedBox(width: 10),
              _metaChipShimmer(valueWidth: 48),
              const SizedBox(width: 10),
              _metaChipShimmer(valueWidth: 80),
            ],
          ),
          const SizedBox(height: 20),
          Skeleton(height: 46, width: double.infinity, cornerRadius: 12),
        ],
      ),
    );
  }

  Widget _metaChipShimmer({double valueWidth = 60}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Skeleton(height: 10, width: 50),
        const SizedBox(height: 5),
        Skeleton(height: 13, width: valueWidth),
      ],
    );
  }

  // ── Stats grid ────────────────────────────────────────────────────────────────

  Widget _statsGridShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
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
      ),
    );
  }

  Widget _statCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 29, height: 29, cornerRadius: 9),
              Skeleton(width: 50, height: 20, cornerRadius: 20),
            ],
          ),
          const SizedBox(height: 14),
          const Skeleton(height: 24, width: 70),
          const SizedBox(height: 5),
          const Skeleton(height: 11, width: 55),
        ],
      ),
    );
  }

  // ── Transaction list ──────────────────────────────────────────────────────────

  Widget _transactionListShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Skeleton(height: 16, width: 110),
              Skeleton(height: 30, width: 70, cornerRadius: 8),
            ],
          ),
          const SizedBox(height: 12),
          // Filter chips
          Row(
            children: List.generate(5, (i) {
              final widths = [36.0, 50.0, 60.0, 42.0, 58.0];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Skeleton(
                  height: 32,
                  width: widths[i],
                  cornerRadius: 20,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Transaction cards
          ...List.generate(4, (_) => _transactionCardShimmer()),
        ],
      ),
    );
  }

  Widget _transactionCardShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Skeleton(width: 42, height: 42, cornerRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 13, width: double.infinity),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Skeleton(height: 18, width: 42, cornerRadius: 20),
                    const SizedBox(width: 8),
                    const Skeleton(height: 11, width: 50),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Skeleton(height: 14, width: 70),
              SizedBox(height: 5),
              Skeleton(height: 11, width: 50),
            ],
          ),
        ],
      ),
    );
  }

  // ── Generic section card (Payout / Fee) ──────────────────────────────────────

  Widget _sectionCardShimmer({required int rows, required bool hasButton}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Skeleton(width: 32, height: 32, cornerRadius: 10),
              const SizedBox(width: 10),
              const Skeleton(height: 14, width: 120),
            ],
          ),
          const SizedBox(height: 14),
          const Skeleton(height: 1, width: double.infinity),
          ...List.generate(rows, (i) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Skeleton(height: 13, width: 110),
                      Skeleton(height: 13, width: 70, cornerRadius: 4),
                    ],
                  ),
                ),
                if (i < rows - 1)
                  const Skeleton(height: 1, width: double.infinity),
              ],
            );
          }),
          if (hasButton) ...[
            const SizedBox(height: 4),
            Skeleton(height: 42, width: double.infinity, cornerRadius: 10),
          ],
        ],
      ),
    );
  }

  // ── Tax reports ───────────────────────────────────────────────────────────────

  Widget _taxReportsShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Skeleton(width: 32, height: 32, cornerRadius: 10),
              const SizedBox(width: 10),
              const Skeleton(height: 14, width: 90),
            ],
          ),
          const SizedBox(height: 14),
          const Skeleton(height: 1, width: double.infinity),
          ...List.generate(3, (i) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Skeleton(width: 33, height: 33, cornerRadius: 9),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Skeleton(height: 13, width: double.infinity),
                            SizedBox(height: 5),
                            Skeleton(height: 11, width: 80),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Skeleton(height: 30, width: 52, cornerRadius: 8),
                    ],
                  ),
                ),
                if (i < 2) const Skeleton(height: 1, width: double.infinity),
              ],
            );
          }),
        ],
      ),
    );
  }
}
