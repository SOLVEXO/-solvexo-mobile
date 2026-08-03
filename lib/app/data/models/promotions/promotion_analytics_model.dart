/// GET /api/promotions/:storeId/analytics — impressions/clicks/conversions
/// rollup across a seller's store banners + resulting promotion banners.
class PromotionAnalyticsDayModel {
  final String date; // yyyy-MM-dd
  final int impressions;
  final int clicks;
  final double revenueUSD;

  const PromotionAnalyticsDayModel({
    required this.date,
    required this.impressions,
    required this.clicks,
    required this.revenueUSD,
  });

  factory PromotionAnalyticsDayModel.fromJson(Map<String, dynamic> json) => PromotionAnalyticsDayModel(
        date: json['date'] as String? ?? '',
        impressions: json['impressions'] as int? ?? 0,
        clicks: json['clicks'] as int? ?? 0,
        revenueUSD: (json['revenueUSD'] as num?)?.toDouble() ?? 0,
      );
}

class PromotionAnalyticsModel {
  final int impressions;
  final int clicks;
  final int conversions;
  final double revenueUSD;
  final int orders;
  final double ctr;
  final List<PromotionAnalyticsDayModel> byDate;

  const PromotionAnalyticsModel({
    required this.impressions,
    required this.clicks,
    required this.conversions,
    required this.revenueUSD,
    required this.orders,
    required this.ctr,
    required this.byDate,
  });

  factory PromotionAnalyticsModel.fromJson(Map<String, dynamic> json) => PromotionAnalyticsModel(
        impressions: json['impressions'] as int? ?? 0,
        clicks: json['clicks'] as int? ?? 0,
        conversions: json['conversions'] as int? ?? 0,
        revenueUSD: (json['revenueUSD'] as num?)?.toDouble() ?? 0,
        orders: json['orders'] as int? ?? 0,
        ctr: (json['ctr'] as num?)?.toDouble() ?? 0,
        byDate: (json['byDate'] as List? ?? [])
            .map((e) => PromotionAnalyticsDayModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static const empty = PromotionAnalyticsModel(
    impressions: 0,
    clicks: 0,
    conversions: 0,
    revenueUSD: 0,
    orders: 0,
    ctr: 0,
    byDate: [],
  );
}
