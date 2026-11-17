class RevenuePointModel {
  final DateTime date;
  final double grossRevenue;
  final double netRevenue;

  const RevenuePointModel({required this.date, required this.grossRevenue, required this.netRevenue});

  factory RevenuePointModel.fromJson(Map<String, dynamic> json) {
    return RevenuePointModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble() ?? 0,
      netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrderPointModel {
  final DateTime date;
  final int orderCount;
  final int cancelledOrdersCount;
  final int refundedOrdersCount;

  const OrderPointModel({
    required this.date,
    required this.orderCount,
    required this.cancelledOrdersCount,
    required this.refundedOrdersCount,
  });

  factory OrderPointModel.fromJson(Map<String, dynamic> json) {
    return OrderPointModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      orderCount: json['orderCount'] as int? ?? 0,
      cancelledOrdersCount: json['cancelledOrdersCount'] as int? ?? 0,
      refundedOrdersCount: json['refundedOrdersCount'] as int? ?? 0,
    );
  }
}
