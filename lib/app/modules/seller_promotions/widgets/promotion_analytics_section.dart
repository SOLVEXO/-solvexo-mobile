import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/promotions/promotion_analytics_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// The seller-analytics blue used for the "Clicks" series — same hue as the
/// `products` activity-log category (`activity_log_tile.dart`), reused here
/// for a second series alongside `AppColors.primaryColor`. Validated against
/// the app's white card surface with `dataviz`'s
/// `scripts/validate_palette.js` ("#d97757,#2563EB" — all checks pass,
/// worst-case CVD ΔE 27.0).
const Color _kClicksSeriesColor = Color(0xFF2563EB);

String _fmtCount(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';

/// Stat-tile grid (impressions/clicks/conversions/revenue/orders/ctr) for
/// [SellerPromotionsView], plus — only when there are enough points to read
/// as a trend rather than noise — a small impressions/clicks line chart.
/// Revenue is deliberately left out of the chart: it's a different unit
/// (dollars vs. raw counts) from impressions/clicks, and this app never
/// mixes two scales on one axis — it gets its own stat tile instead.
class PromotionAnalyticsSection extends StatelessWidget {
  final PromotionAnalyticsModel data;
  const PromotionAnalyticsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final showTrend = data.byDate.length >= 4 && data.byDate.any((d) => d.impressions > 0 || d.clicks > 0);

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
            text: 'Performance',
            color: AppColors.black2,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: BaseSpacing.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: BaseSpacing.xs,
            crossAxisSpacing: BaseSpacing.xs,
            childAspectRatio: 1.55,
            children: [
              _StatTile(label: 'Impressions', value: _fmtCount(data.impressions)),
              _StatTile(label: 'Clicks', value: _fmtCount(data.clicks)),
              _StatTile(label: 'CTR', value: '${(data.ctr * 100).toStringAsFixed(1)}%'),
              _StatTile(label: 'Conversions', value: _fmtCount(data.conversions)),
              _StatTile(label: 'Orders', value: _fmtCount(data.orders)),
              _StatTile(label: 'Revenue', value: '\$${data.revenueUSD.toStringAsFixed(2)}'),
            ],
          ),
          if (showTrend) ...[
            SizedBox(height: BaseSpacing.md),
            const _Legend(),
            SizedBox(height: BaseSpacing.xs),
            SizedBox(height: 170, child: _TrendChart(byDate: data.byDate)),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: BaseSpacing.xs),
      decoration: BoxDecoration(color: AppColors.lightGrey10, borderRadius: BorderRadius.circular(BaseRadius.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: label,
            color: AppColors.gray600,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          CustomText(
            text: value,
            color: AppColors.black2,
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.w700,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendItem(color: AppColors.primaryColor, label: 'Impressions'),
        SizedBox(width: 14),
        _LegendItem(color: _kClicksSeriesColor, label: 'Clicks'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        CustomText(text: label, fontSize: AppFontSize.tiny, color: AppColors.gray600, fontWeight: FontWeight.w600),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<PromotionAnalyticsDayModel> byDate;
  const _TrendChart({required this.byDate});

  @override
  Widget build(BuildContext context) {
    final maxY = byDate
        .map((d) => d.impressions > d.clicks ? d.impressions : d.clicks)
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();
    final ceilingY = maxY == 0 ? 10.0 : maxY * 1.2;
    final impressionSpots = byDate.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.impressions.toDouble())).toList();
    final clickSpots = byDate.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.clicks.toDouble())).toList();
    final step = (byDate.length / 5).ceil().clamp(1, byDate.length);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: ceilingY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ceilingY / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.lightGrey2, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => CustomText(
                text: value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                color: AppColors.gray600,
                fontWeight: FontWeight.w600,
                fontSize: 9.5,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: step.toDouble(),
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= byDate.length) return const SizedBox.shrink();
                final d = DateTime.tryParse(byDate[i].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: CustomText(
                    text: d != null ? DateFormat('M/d').format(d) : byDate[i].date,
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
              final isImpressions = s.barIndex == 0;
              final point = byDate[s.x.toInt()];
              return LineTooltipItem(
                '${isImpressions ? 'Impressions' : 'Clicks'}: ${isImpressions ? point.impressions : point.clicks}',
                const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: impressionSpots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.primaryColor,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: clickSpots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: _kClicksSeriesColor,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
