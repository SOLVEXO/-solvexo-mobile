import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/analytics/traffic_source_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const _kSourceColors = {
  'marketplace_search': AppColors.primaryColor,
  'direct_link': AppColors.black2,
  'social_media': AppColors.gray600,
  'email': AppColors.seaGreen,
  'other': AppColors.accentColor,
};

class AnalyticsTrafficDonut extends StatefulWidget {
  final List<TrafficSourceModel> sources;
  const AnalyticsTrafficDonut({super.key, required this.sources});

  @override
  State<AnalyticsTrafficDonut> createState() => _AnalyticsTrafficDonutState();
}

class _AnalyticsTrafficDonutState extends State<AnalyticsTrafficDonut> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.sources.fold<int>(0, (sum, s) => sum + s.count);

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
            text: 'Traffic Sources',
            color: AppColors.black2,
            fontSize: AppFontSize.extraSmall,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: BaseSpacing.md),
          if (total == 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSpacing.xl),
              child: Center(
                child: CustomText(
                  text: 'No orders in this period',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 32,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                          });
                        },
                      ),
                      sections: widget.sources.asMap().entries.map((e) {
                        final isTouched = e.key == _touchedIndex;
                        return PieChartSectionData(
                          value: e.value.count.toDouble(),
                          color: _kSourceColors[e.value.source] ?? AppColors.lightGrey,
                          radius: isTouched ? 24 : 20,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: BaseSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.sources.map((s) => _LegendRow(source: s)).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final TrafficSourceModel source;
  const _LegendRow({required this.source});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs / 2),
      child: Row(
        children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: _kSourceColors[source.source] ?? AppColors.lightGrey, shape: BoxShape.circle)),
          SizedBox(width: BaseSpacing.xs),
          Expanded(
            child: CustomText(
              text: source.label,
              color: AppColors.black2,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CustomText(
            text: '${source.percent.toStringAsFixed(0)}%',
            color: AppColors.black2,
            fontSize: AppFontSize.tiny,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}
