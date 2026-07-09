class AnalyticsOverviewModel {
  final double grossRevenue;
  final double totalRevenue; // net of refunds
  final double? totalRevenueChangePercent;
  final int totalOrders;
  final int totalOrdersChange;
  final double avgOrderValue;
  final double? avgOrderValueChangePercent;
  final double repeatBuyerPercent;
  final String repeatBuyerTrend; // improving | declining | flat
  final double totalRefunds;
  final double refundRatePercent;
  final int cancelledOrders;
  final int newCustomersCount;
  final int returningCustomersCount;

  const AnalyticsOverviewModel({
    required this.grossRevenue,
    required this.totalRevenue,
    this.totalRevenueChangePercent,
    required this.totalOrders,
    required this.totalOrdersChange,
    required this.avgOrderValue,
    this.avgOrderValueChangePercent,
    required this.repeatBuyerPercent,
    required this.repeatBuyerTrend,
    required this.totalRefunds,
    required this.refundRatePercent,
    required this.cancelledOrders,
    required this.newCustomersCount,
    required this.returningCustomersCount,
  });

  static const empty = AnalyticsOverviewModel(
    grossRevenue: 0,
    totalRevenue: 0,
    totalOrders: 0,
    totalOrdersChange: 0,
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
      totalRevenueChangePercent: (json['totalRevenueChangePercent'] as num?)?.toDouble(),
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalOrdersChange: json['totalOrdersChange'] as int? ?? 0,
      avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0,
      avgOrderValueChangePercent: (json['avgOrderValueChangePercent'] as num?)?.toDouble(),
      repeatBuyerPercent: (json['repeatBuyerPercent'] as num?)?.toDouble() ?? 0,
      repeatBuyerTrend: json['repeatBuyerTrend'] as String? ?? 'flat',
      totalRefunds: (json['totalRefunds'] as num?)?.toDouble() ?? 0,
      refundRatePercent: (json['refundRatePercent'] as num?)?.toDouble() ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      newCustomersCount: json['newCustomersCount'] as int? ?? 0,
      returningCustomersCount: json['returningCustomersCount'] as int? ?? 0,
    );
  }
}
