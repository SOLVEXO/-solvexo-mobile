import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';

class CampaignsShimmer extends StatelessWidget {
  const CampaignsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(BaseSpacing.md),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(width: double.infinity, height: 110, cornerRadius: 0),
            Padding(
              padding: EdgeInsets.all(BaseSpacing.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Skeleton(width: 160, height: 16, cornerRadius: 6),
                  SizedBox(height: BaseSpacing.xs),
                  const Skeleton(width: 220, height: 12, cornerRadius: 6),
                  SizedBox(height: BaseSpacing.sm),
                  Row(
                    children: [
                      const Skeleton(width: 70, height: 24, cornerRadius: 8),
                      SizedBox(width: BaseSpacing.sm),
                      const Skeleton(width: 90, height: 24, cornerRadius: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
