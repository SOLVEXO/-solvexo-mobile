import 'package:book_store_app/app/data/models/analytics/revenue_point_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsOrdersChart extends StatelessWidget {
  final List<OrderPointModel> series;
  final String granularity;

  const AnalyticsOrdersChart({super.key, required this.series, required this.granularity});

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
          Text('Orders Over Time', style: BaseTypography.bodyMedium(color: AppColors.black2).copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: BaseSpacing.md),
          if (series.isEmpty || series.every((s) => s.orderCount == 0))
            SizedBox(
              height: 180,
              child: Center(child: Text('No orders in this period', style: BaseTypography.labelSmall(color: AppColors.gray600))),
            )
          else
            SizedBox(height: 200, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final maxY = series.map((s) => s.orderCount).fold<int>(0, (a, b) => a > b ? a : b).toDouble();
    final step = (series.length / 5).ceil().clamp(1, series.length);

    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 10 : maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY == 0 ? 10 : maxY * 1.2) / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.lightGrey2, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.black2,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final point = series[group.x.toInt()];
              return BarTooltipItem(
                '${_dateLabel(point.date)}\n${point.orderCount} orders',
                BaseTypography.labelSmall(color: AppColors.white).copyWith(fontWeight: FontWeight.w600),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontSize: 9.5),
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
                  child: Text(_dateLabel(series[i].date), style: BaseTypography.labelSmall(color: AppColors.gray600).copyWith(fontSize: 9.5)),
                );
              },
            ),
          ),
        ),
        barGroups: series.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.orderCount.toDouble(),
                color: AppColors.accentColor,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
