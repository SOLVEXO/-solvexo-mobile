class SubscriptionPlanModel {
  final String id;
  final String name;
  final String? description;
  final double monthlyPriceUSD;
  final double? yearlyPriceUSD;
  final String displayCurrency;
  final List<String> features;
  final String status; // 'active' | 'archived'
  final int subscriberCount;
  final double monthlyRecurringRevenueUSD;
  final double displayMonthlyPrice;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.monthlyPriceUSD,
    this.yearlyPriceUSD,
    required this.displayCurrency,
    required this.features,
    required this.status,
    this.subscriberCount = 0,
    this.monthlyRecurringRevenueUSD = 0,
    this.displayMonthlyPrice = 0,
  });

  bool get isActive => status == 'active';

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      monthlyPriceUSD: (json['monthlyPriceUSD'] as num?)?.toDouble() ?? 0,
      yearlyPriceUSD: (json['yearlyPriceUSD'] as num?)?.toDouble(),
      displayCurrency: json['displayCurrency'] as String? ?? 'USD',
      features: (json['features'] as List? ?? []).cast<String>(),
      status: json['status'] as String? ?? 'active',
      subscriberCount: json['subscriberCount'] as int? ?? 0,
      monthlyRecurringRevenueUSD: (json['monthlyRecurringRevenueUSD'] as num?)?.toDouble() ?? 0,
      displayMonthlyPrice: (json['displayMonthlyPrice'] as num?)?.toDouble() ?? (json['monthlyPriceUSD'] as num?)?.toDouble() ?? 0,
    );
  }
}
