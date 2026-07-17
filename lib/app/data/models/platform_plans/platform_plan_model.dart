/// A platform plan the marketplace sells to sellers (admin-managed in DB) —
/// mirrors `solvexo-api`'s `PlatformPlan` schema, served by
/// `GET /api/platform-plans/public`.
class PlatformPlanModel {
  final String id;
  final String name;
  final String? description;
  final String? badge;
  final bool isFree;
  final bool isCustomPricing;
  final double? monthlyPriceUSD;
  final double? yearlyPriceUSD;
  final int trialDays;
  final List<String> featureBullets;
  final PlatformPlanLimits limits;

  const PlatformPlanModel({
    required this.id,
    required this.name,
    this.description,
    this.badge,
    required this.isFree,
    required this.isCustomPricing,
    this.monthlyPriceUSD,
    this.yearlyPriceUSD,
    required this.trialDays,
    required this.featureBullets,
    required this.limits,
  });

  double priceFor(String interval) =>
      interval == 'yearly' ? (yearlyPriceUSD ?? (monthlyPriceUSD ?? 0) * 12) : (monthlyPriceUSD ?? 0);

  factory PlatformPlanModel.fromJson(Map<String, dynamic> json) {
    return PlatformPlanModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      badge: json['badge'] as String?,
      isFree: json['isFree'] as bool? ?? false,
      isCustomPricing: json['isCustomPricing'] as bool? ?? false,
      monthlyPriceUSD: (json['monthlyPriceUSD'] as num?)?.toDouble(),
      yearlyPriceUSD: (json['yearlyPriceUSD'] as num?)?.toDouble(),
      trialDays: json['trialDays'] as int? ?? 0,
      featureBullets: (json['featureBullets'] as List? ?? []).cast<String>(),
      limits: PlatformPlanLimits.fromJson(json['limits'] as Map<String, dynamic>?),
    );
  }
}

/// `plan.limits` — numeric limits use -1 for "unlimited".
class PlatformPlanLimits {
  final int maxProducts;
  final int maxStaffAccounts;
  final int maxPosLocations;
  final int aiCreditsPerMonth;
  final double transactionFeeRate;
  final bool prioritySupport;

  const PlatformPlanLimits({
    required this.maxProducts,
    required this.maxStaffAccounts,
    required this.maxPosLocations,
    required this.aiCreditsPerMonth,
    required this.transactionFeeRate,
    required this.prioritySupport,
  });

  factory PlatformPlanLimits.fromJson(Map<String, dynamic>? json) {
    json ??= const {};
    return PlatformPlanLimits(
      maxProducts: json['maxProducts'] as int? ?? 0,
      maxStaffAccounts: json['maxStaffAccounts'] as int? ?? 0,
      maxPosLocations: json['maxPosLocations'] as int? ?? 0,
      aiCreditsPerMonth: json['aiCreditsPerMonth'] as int? ?? 0,
      transactionFeeRate: (json['transactionFeeRate'] as num?)?.toDouble() ?? 0,
      prioritySupport: json['prioritySupport'] as bool? ?? false,
    );
  }

  static String limitLabel(int limit) => limit == -1 ? 'Unlimited' : '$limit';
}
