/// A platform tier the seller can subscribe to (Starter/Basic/Pro/Enterprise) —
/// the marketplace's own pricing, not a plan the seller sells to their buyers.
class PlatformTierModel {
  final String tier; // 'starter' | 'basic' | 'pro' | 'enterprise'
  final String name;
  final double monthlyPriceUSD;
  final double? yearlyPriceUSD;
  final int? productLimit; // null = unlimited
  final bool posEligible;
  final List<String> features;

  const PlatformTierModel({
    required this.tier,
    required this.name,
    required this.monthlyPriceUSD,
    this.yearlyPriceUSD,
    this.productLimit,
    required this.posEligible,
    required this.features,
  });

  bool get isFree => monthlyPriceUSD <= 0;

  factory PlatformTierModel.fromJson(Map<String, dynamic> json) {
    return PlatformTierModel(
      tier: json['tier'] as String? ?? 'starter',
      name: json['name'] as String? ?? '',
      monthlyPriceUSD: (json['monthlyPriceUSD'] as num?)?.toDouble() ?? 0,
      yearlyPriceUSD: (json['yearlyPriceUSD'] as num?)?.toDouble(),
      productLimit: json['productLimit'] as int?,
      posEligible: json['posEligible'] as bool? ?? false,
      features: (json['features'] as List? ?? []).cast<String>(),
    );
  }
}
