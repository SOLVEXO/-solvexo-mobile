import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:flutter/material.dart';

class AnalyticsShimmer extends StatelessWidget {
  const AnalyticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(BaseSpacing.md),
      children: [
        Row(
          children: [
            Expanded(child: _card(90)),
            SizedBox(width: BaseSpacing.sm),
            Expanded(child: _card(90)),
          ],
        ),
        SizedBox(height: BaseSpacing.sm),
        Row(
          children: [
            Expanded(child: _card(90)),
            SizedBox(width: BaseSpacing.sm),
            Expanded(child: _card(90)),
          ],
        ),
        SizedBox(height: BaseSpacing.md),
        _card(220),
        SizedBox(height: BaseSpacing.md),
        _card(220),
      ],
    );
  }

  Widget _card(double height) {
    return Container(
      height: height,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(BaseRadius.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Skeleton(width: 80, height: 18, cornerRadius: 6),
          const SizedBox(height: 8),
          const Skeleton(width: 120, height: 12, cornerRadius: 6),
        ],
      ),
    );
  }
}
