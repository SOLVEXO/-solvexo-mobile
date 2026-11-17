class TopProductAnalyticsModel {
  final String productId;
  final String name;
  final int orderCount;
  final int unitsSold;
  final double revenue;

  const TopProductAnalyticsModel({
    required this.productId,
    required this.name,
    required this.orderCount,
    required this.unitsSold,
    required this.revenue,
  });

  factory TopProductAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return TopProductAnalyticsModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      orderCount: json['orderCount'] as int? ?? 0,
      unitsSold: json['unitsSold'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}
