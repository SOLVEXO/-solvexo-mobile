/// Usage-vs-limit summary from `GET /api/platform-plans/:storeId/entitlements`
/// — powers the "Usage" section of the Plan & Billing screen.
class EntitlementUsage {
  final int limit; // -1 = unlimited
  final int used;

  const EntitlementUsage({required this.limit, required this.used});

  bool get isUnlimited => limit == -1;
  double get ratio => isUnlimited || limit == 0 ? 0 : (used / limit).clamp(0.0, 1.0);
  String get label => isUnlimited ? '$used / Unlimited' : '$used / $limit';

  factory EntitlementUsage.fromJson(Map<String, dynamic>? json) {
    json ??= const {};
    return EntitlementUsage(
      limit: json['limit'] as int? ?? 0,
      used: json['used'] as int? ?? 0,
    );
  }
}

class PlatformEntitlementsModel {
  final String currentPlanName;
  final EntitlementUsage products;
  final EntitlementUsage staffAccounts;
  final EntitlementUsage posLocations;
  final int aiCreditsMonthlyAllowance;
  final int aiCreditsBalance;
  final double transactionFeeRate;
  final bool prioritySupport;

  const PlatformEntitlementsModel({
    required this.currentPlanName,
    required this.products,
    required this.staffAccounts,
    required this.posLocations,
    required this.aiCreditsMonthlyAllowance,
    required this.aiCreditsBalance,
    required this.transactionFeeRate,
    required this.prioritySupport,
  });

  factory PlatformEntitlementsModel.fromJson(Map<String, dynamic> json) {
    final ai = json['aiCredits'] as Map<String, dynamic>? ?? const {};
    return PlatformEntitlementsModel(
      currentPlanName: json['currentPlanName'] as String? ?? 'Free',
      products: EntitlementUsage.fromJson(json['maxProducts'] as Map<String, dynamic>?),
      staffAccounts: EntitlementUsage.fromJson(json['maxStaffAccounts'] as Map<String, dynamic>?),
      posLocations: EntitlementUsage.fromJson(json['maxPosLocations'] as Map<String, dynamic>?),
      aiCreditsMonthlyAllowance: ai['monthlyAllowance'] as int? ?? 0,
      aiCreditsBalance: ai['balance'] as int? ?? 0,
      transactionFeeRate: (json['transactionFeeRate'] as num?)?.toDouble() ?? 0,
      prioritySupport: json['prioritySupport'] as bool? ?? false,
    );
  }
}
