import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class AnalyticsStatsGrid extends StatelessWidget {
  final List<StatItem> stats;

  const AnalyticsStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: stats.map((s) => _StatCard(item: s)).toList(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: item.title,
            fontSize: AppFontSize.verySmall,
            color: AppColors.grey,
          ),
          CustomText(
            text: item.value,
            fontSize: AppFontSize.veryLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          CustomText(
            text: item.change,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w500,
            color: item.isPositive ? AppColors.darkGreen : AppColors.red,
          ),
        ],
      ),
    );
  }
}
