class ProductPerformanceModel {
  final String productId;
  final String name;
  final int unitsSold;
  final double revenue;
  final double refundRatePercent;
  final int currentStock;
  final bool isLowPerformer;

  const ProductPerformanceModel({
    required this.productId,
    required this.name,
    required this.unitsSold,
    required this.revenue,
    required this.refundRatePercent,
    required this.currentStock,
    required this.isLowPerformer,
  });

  factory ProductPerformanceModel.fromJson(Map<String, dynamic> json) {
    return ProductPerformanceModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unitsSold: json['unitsSold'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      refundRatePercent: (json['refundRatePercent'] as num?)?.toDouble() ?? 0,
      currentStock: json['currentStock'] as int? ?? 0,
      isLowPerformer: json['isLowPerformer'] as bool? ?? false,
    );
  }
}
