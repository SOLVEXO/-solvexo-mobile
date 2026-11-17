import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/revenue_point_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/currency_formatter.dart';

/// Interactive revenue-over-time line chart — tap/drag any point to see its
/// exact date and net revenue in a tooltip.
class AnalyticsRevenueChart extends StatelessWidget {
  final List<RevenuePointModel> series;
  final String granularity;
  final String? currency;

  const AnalyticsRevenueChart({super.key, required this.series, required this.granularity, this.currency});

  String _dateLabel(DateTime d) => switch (granularity) {
        'month' => DateFormat('MMM').format(d),
        _ => DateFormat('MMM d').format(d),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(BaseSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(BaseRadius.lg),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Revenue Over Time',
            color: AppColors.black2,
            fontSize: AppFontSize.extraSmall,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: BaseSpacing.md),
          if (series.isEmpty || series.every((s) => s.netRevenue == 0))
            SizedBox(
              height: 180,
              child: Center(
                child: CustomText(
                  text: 'No revenue in this period',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            SizedBox(height: 200, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final maxY = series.map((s) => s.netRevenue).fold<double>(0, (a, b) => a > b ? a : b);
    final spots = series.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.netRevenue)).toList();
    final step = (series.length / 5).ceil().clamp(1, series.length);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 10 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY == 0 ? 10 : maxY * 1.2) / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.lightGrey2, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => CustomText(
                text: CurrencyFormatter.compact(value, currency),
                color: AppColors.gray600,
                fontWeight: FontWeight.w600,
                fontSize: 9.5,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: step.toDouble(),
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= series.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: CustomText(
                    text: _dateLabel(series[i].date),
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                    fontSize: 9.5,
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.black2,
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              final point = series[s.x.toInt()];
              return LineTooltipItem(
                '${_dateLabel(point.date)}\n${CurrencyFormatter.amount(point.netRevenue, currency)}',
                BaseTypography.labelSmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.primaryColor,
            barWidth: 2.5,
            dotData: FlDotData(show: series.length <= 14),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryColor.withOpacity(0.25), AppColors.primaryColor.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
