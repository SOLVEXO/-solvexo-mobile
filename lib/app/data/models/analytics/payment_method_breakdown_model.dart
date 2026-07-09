class PaymentMethodBreakdownModel {
  final String paymentType;
  final String label;
  final int orderCount;
  final double revenue;

  const PaymentMethodBreakdownModel({
    required this.paymentType,
    required this.label,
    required this.orderCount,
    required this.revenue,
  });

  factory PaymentMethodBreakdownModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodBreakdownModel(
      paymentType: json['paymentType'] as String? ?? '',
      label: json['label'] as String? ?? json['paymentType'] as String? ?? '',
      orderCount: json['orderCount'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RevenueBreakdownModel {
  final double oneTimeOrderRevenue;
  final double recurringSubscriptionRevenue;
  final double totalRevenue;

  const RevenueBreakdownModel({
    required this.oneTimeOrderRevenue,
    required this.recurringSubscriptionRevenue,
    required this.totalRevenue,
  });

  static const empty = RevenueBreakdownModel(oneTimeOrderRevenue: 0, recurringSubscriptionRevenue: 0, totalRevenue: 0);

  factory RevenueBreakdownModel.fromJson(Map<String, dynamic> json) {
    return RevenueBreakdownModel(
      oneTimeOrderRevenue: (json['oneTimeOrderRevenue'] as num?)?.toDouble() ?? 0,
      recurringSubscriptionRevenue: (json['recurringSubscriptionRevenue'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    );
  }
}
