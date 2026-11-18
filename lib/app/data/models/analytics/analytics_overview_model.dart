// GET /api/seller/analytics/overview?compareToPreviousPeriod=true
// (backend 5adba44 analytics.service.ts getOverview). Live, test store
// 2026-11-18: {..., bookedValue, collected, grossRevenue, totalRevenue,
// totalOrders, freeClaims, avgOrderValue, repeatBuyerPercent, ...,
// repeatBuyerTrend, bookedValueChangePercent, collectedChangePercent,
// totalOrdersChange, freeClaimsChange, avgOrderValueChangePercent,
// previousPeriod:{...}}. Change fields are absent without the compare flag;
// a percent is null when the previous period was 0 and this one is not.
class AnalyticsOverviewModel {
  final double grossRevenue;
  final double totalRevenue; // net of refunds
  /// Booked value (docs: "booked vs collected"); grossRevenue is its alias.
  final double bookedValue;
  final double collected;
  final double? bookedValueChangePercent;
  final double? collectedChangePercent;
  final int totalOrders;
  /// Absolute change vs the previous period; null = no comparison sent.
  final int? totalOrdersChange;
  final double avgOrderValue;
  final double? avgOrderValueChangePercent;
  final double repeatBuyerPercent;
  final String repeatBuyerTrend; // improving | declining | flat
  final double totalRefunds;
  final double refundRatePercent;
  final int cancelledOrders;
  final int newCustomersCount;
  final int returningCustomersCount;
  // null when the seller's stores span more than one baseCurrency — can't
  // be labeled with a single symbol.
  final String? currency;

  const AnalyticsOverviewModel({
    required this.grossRevenue,
    required this.totalRevenue,
    this.bookedValue = 0,
    this.collected = 0,
    this.bookedValueChangePercent,
    this.collectedChangePercent,
    required this.totalOrders,
    this.totalOrdersChange,
    required this.avgOrderValue,
    this.avgOrderValueChangePercent,
    required this.repeatBuyerPercent,
    required this.repeatBuyerTrend,
    required this.totalRefunds,
    required this.refundRatePercent,
    required this.cancelledOrders,
    required this.newCustomersCount,
    required this.returningCustomersCount,
    this.currency,
  });

  static const empty = AnalyticsOverviewModel(
    grossRevenue: 0,
    totalRevenue: 0,
    totalOrders: 0,
    avgOrderValue: 0,
    repeatBuyerPercent: 0,
    repeatBuyerTrend: 'flat',
    totalRefunds: 0,
    refundRatePercent: 0,
    cancelledOrders: 0,
    newCustomersCount: 0,
    returningCustomersCount: 0,
  );

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      bookedValue: ((json['bookedValue'] ?? json['grossRevenue']) as num?)?.toDouble() ?? 0,
      collected: (json['collected'] as num?)?.toDouble() ?? 0,
      bookedValueChangePercent: (json['bookedValueChangePercent'] as num?)?.toDouble(),
      collectedChangePercent: (json['collectedChangePercent'] as num?)?.toDouble(),
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalOrdersChange: (json['totalOrdersChange'] as num?)?.toInt(),
      avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0,
      avgOrderValueChangePercent: (json['avgOrderValueChangePercent'] as num?)?.toDouble(),
      repeatBuyerPercent: (json['repeatBuyerPercent'] as num?)?.toDouble() ?? 0,
      repeatBuyerTrend: json['repeatBuyerTrend'] as String? ?? 'flat',
      totalRefunds: (json['totalRefunds'] as num?)?.toDouble() ?? 0,
      refundRatePercent: (json['refundRatePercent'] as num?)?.toDouble() ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      newCustomersCount: json['newCustomersCount'] as int? ?? 0,
      returningCustomersCount: json['returningCustomersCount'] as int? ?? 0,
      currency: json['currency'] as String?,
    );
  }
}
