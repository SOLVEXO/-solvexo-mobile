import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class AnalyticsRevenueCard extends StatelessWidget {
  final AnalyticsData data;

  const AnalyticsRevenueCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
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
        children: [
          CustomText(
            text: data.revenueTitle,
            fontSize: AppFontSize.extraSmall,
            fontWeight: FontWeight.w600,
            color: AppColors.black2,
          ),
          const SizedBox(height: 6),
          CustomText(
            text: '\$${_formatAmount(data.revenue)}',
            fontSize: AppFontSize.veryLarge3,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                data.revenuePositive
                    ? Icons.arrow_drop_up_rounded
                    : Icons.arrow_drop_down_rounded,
                size: 18,
                color: data.revenuePositive
                    ? AppColors.darkGreen
                    : AppColors.red,
              ),
              CustomText(
                text: data.revenueChange,
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w500,
                color: data.revenuePositive
                    ? AppColors.darkGreen
                    : AppColors.red,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _BarChart(bars: data.bars),
        ],
      ),
    );
  }

  String _formatAmount(double v) {
    if (v >= 1000) {
      final thousands = v / 1000;
      return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}K';
    }
    return v.toStringAsFixed(2);
  }
}

// ── Custom bar chart ─────────────────────────────────────────────────────────
class _BarChart extends StatelessWidget {
  final List<BarEntry> bars;

  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    final maxVal = bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars
            .map(
              (bar) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _Bar(
                          fraction: maxVal > 0 ? bar.value / maxVal : 0,
                          isHighest: bar.value == maxVal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomText(
                        text: bar.label,
                        fontSize: AppFontSize.tiny,
                        color: AppColors.lightGrey5,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double fraction;
  final bool isHighest;

  const _Bar({required this.fraction, required this.isHighest});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final barH = (constraints.maxHeight * fraction).clamp(
          6.0,
          constraints.maxHeight,
        );
        return Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            height: barH,
            decoration: BoxDecoration(
              color: isHighest
                  ? AppColors.primaryColor
                  : AppColors.primaryColor.withOpacity(0.18),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }
}
