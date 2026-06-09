import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StoreProfileShimmer extends StatelessWidget {
  const StoreProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            _hero(context),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _statsStrip(),
                    const SizedBox(height: 16),
                    _textCard(lines: 3),
                    const SizedBox(height: 16),
                    _textCard(lines: 2),
                    const SizedBox(height: 16),
                    _infoRowsCard(rows: 3),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero — matches StoreProfileHero gradient section ─────────────────────────
  Widget _hero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top > 0 ? 20 : 30,
        20,
        52,
      ),
      color: AppColors.shimmerBase,
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.shimmerShapeAlt,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 14),
          // Store name
          const Skeleton(height: 18, width: 160, switchColor: false),
          const SizedBox(height: 10),
          // Pills row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.shimmerShapeAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 76,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.shimmerShapeAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats strip — matches StoreStatsStrip (4 cells + 3 dividers) ─────────────
  Widget _statsStrip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        ),
        child: Row(
          children: List.generate(7, (i) {
            if (i.isOdd) {
              return Container(width: 1, height: 36, color: AppColors.shimmerBase);
            }
            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Skeleton(height: 14, width: 36),
                  SizedBox(height: 6),
                  Skeleton(height: 10, width: 48),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Text card — matches StoreAboutCard / StoreContactCard ────────────────────
  Widget _textCard({required int lines}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimen.allPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(height: 10, width: 120),
            const SizedBox(height: 12),
            ...List.generate(lines, (i) => Padding(
              padding: EdgeInsets.only(bottom: i < lines - 1 ? 8 : 0),
              child: Skeleton(
                height: 12,
                width: i == lines - 1 ? 180 : double.infinity,
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Info rows card — matches StoreMetaCard (icon + label + value rows) ────────
  Widget _infoRowsCard({required int rows}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        ),
        child: Column(
          children: List.generate(rows, (i) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Skeleton(width: 36, height: 36, cornerRadius: 10),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Skeleton(height: 10, width: 70),
                          SizedBox(height: 6),
                          Skeleton(height: 12, width: 130),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < rows - 1)
                const Divider(height: 1, indent: 54, color: AppColors.lightGrey2),
            ],
          )),
        ),
      ),
    );
  }
}
