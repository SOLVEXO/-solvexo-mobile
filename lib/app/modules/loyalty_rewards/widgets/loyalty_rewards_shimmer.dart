import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';

class LoyaltyRewardsShimmer extends StatelessWidget {
  const LoyaltyRewardsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(BaseSpacing.md),
      children: [
        Container(height: 130, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.xl))),
        SizedBox(height: BaseSpacing.md),
        ...List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: BaseSpacing.sm),
            child: Container(
              height: 76,
              padding: EdgeInsets.all(BaseSpacing.sm + 2),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg)),
              child: Row(
                children: [
                  const Skeleton(width: 48, height: 48, cornerRadius: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Skeleton(width: 140, height: 12, cornerRadius: 6),
                        SizedBox(height: 8),
                        Skeleton(width: 80, height: 10, cornerRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
