import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';

class CouponsShimmer extends StatelessWidget {
  const CouponsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(BaseSpacing.md),
      itemCount: 5,
      separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
      itemBuilder: (_, __) => Container(
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Skeleton(width: 90, height: 24, cornerRadius: 8),
                SizedBox(width: BaseSpacing.sm),
                const Skeleton(width: 70, height: 16, cornerRadius: 6),
              ],
            ),
            SizedBox(height: BaseSpacing.sm),
            const Skeleton(width: 200, height: 12, cornerRadius: 6),
          ],
        ),
      ),
    );
  }
}
