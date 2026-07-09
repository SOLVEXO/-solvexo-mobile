import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';

class SubscriptionsShimmer extends StatelessWidget {
  const SubscriptionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(BaseSpacing.md),
      children: [
        Row(
          children: [
            Expanded(child: _card()),
            SizedBox(width: BaseSpacing.sm),
            Expanded(child: _card()),
          ],
        ),
        SizedBox(height: BaseSpacing.sm),
        Row(
          children: [
            Expanded(child: _card()),
            SizedBox(width: BaseSpacing.sm),
            Expanded(child: _card()),
          ],
        ),
        SizedBox(height: BaseSpacing.md),
        Container(height: 140, decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg))),
      ],
    );
  }

  Widget _card() {
    return Container(
      height: 90,
      padding: EdgeInsets.all(BaseSpacing.sm),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Skeleton(width: 70, height: 20, cornerRadius: 6),
          const SizedBox(height: 8),
          const Skeleton(width: 90, height: 12, cornerRadius: 6),
        ],
      ),
    );
  }
}
