import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SellerHomeShimmer extends StatelessWidget {
  const SellerHomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statsCard(),
            const SizedBox(height: 16),
            _quickActions(),
            const SizedBox(height: 16),
            _lowStockAlert(),
            const SizedBox(height: 20),
            _sectionHeader(),
            const SizedBox(height: 12),
            _orderCard(),
            const SizedBox(height: 10),
            _orderCard(),
            const SizedBox(height: 10),
            _orderCard(),
            const SizedBox(height: 20),
            _sectionHeader(),
            const SizedBox(height: 12),
            _messageCard(),
            const SizedBox(height: 10),
            _messageCard(),
          ],
        ),
      ),
    );
  }

  // ── Stats card ──────────────────────────────────────────────────────────────
  Widget _statsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 12, width: 100),
          const SizedBox(height: 10),
          const Skeleton(height: 32, width: 160),
          const SizedBox(height: 10),
          const Skeleton(height: 12, width: 140),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Skeleton(height: 10, width: 40),
                    SizedBox(height: 6),
                    Skeleton(height: 14, width: 55),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick actions grid ──────────────────────────────────────────────────────
  Widget _quickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 16, width: 120),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(
              4,
              (_) => Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Low stock alert ─────────────────────────────────────────────────────────
  Widget _lowStockAlert() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Skeleton(width: 24, height: 24, cornerRadius: 6),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Skeleton(height: 13, width: double.infinity),
                  SizedBox(height: 6),
                  Skeleton(height: 11, width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────
  Widget _sectionHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Skeleton(height: 16, width: 120),
    );
  }

  // ── Message card ────────────────────────────────────────────────────────────
  Widget _messageCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Skeleton(width: 44, height: 44, cornerRadius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(child: Skeleton(height: 14, width: double.infinity)),
                      SizedBox(width: 40),
                      Skeleton(height: 11, width: 44),
                    ],
                  ),
                  const SizedBox(height: 7),
                  const Skeleton(height: 11, width: double.infinity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order card ──────────────────────────────────────────────────────────────
  Widget _orderCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton(height: 14, width: 60),
                SizedBox(height: 6),
                Skeleton(height: 11, width: 90),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Skeleton(height: 22, width: 80, cornerRadius: 20),
                SizedBox(height: 6),
                Skeleton(height: 13, width: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
