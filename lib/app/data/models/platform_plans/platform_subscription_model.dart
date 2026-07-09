import 'package:book_store_app/app/data/models/platform_plans/platform_tier_model.dart';

class PosAddonModel {
  final bool active;
  final DateTime? activatedAt;
  final DateTime? nextBillingDate;
  final DateTime? canceledAt;

  const PosAddonModel({required this.active, this.activatedAt, this.nextBillingDate, this.canceledAt});

  static const empty = PosAddonModel(active: false);

  factory PosAddonModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PosAddonModel.empty;
    return PosAddonModel(
      active: json['active'] as bool? ?? false,
      activatedAt: json['activatedAt'] != null ? DateTime.tryParse(json['activatedAt'] as String) : null,
      nextBillingDate: json['nextBillingDate'] != null ? DateTime.tryParse(json['nextBillingDate'] as String) : null,
      canceledAt: json['canceledAt'] != null ? DateTime.tryParse(json['canceledAt'] as String) : null,
    );
  }
}

/// The seller's own platform-plan status for one store — separate from any
/// plan they sell to their own buyers.
class PlatformSubscriptionModel {
  final String storeId;
  final String tier;
  final String billingInterval;
  final double amountUSD;
  final String status; // 'active' | 'past_due' | 'canceled'
  final DateTime? currentPeriodEnd;
  final DateTime? nextBillingDate;
  final DateTime? canceledAt;
  final double creditBalanceUSD;
  final PosAddonModel posAddon;
  final PlatformTierModel? tierConfig;
  final bool posAddonEligible;
  final double posAddonMonthlyPriceUSD;

  const PlatformSubscriptionModel({
    required this.storeId,
    required this.tier,
    required this.billingInterval,
    required this.amountUSD,
    required this.status,
    this.currentPeriodEnd,
    this.nextBillingDate,
    this.canceledAt,
    required this.creditBalanceUSD,
    required this.posAddon,
    this.tierConfig,
    required this.posAddonEligible,
    required this.posAddonMonthlyPriceUSD,
  });

  bool get hasPendingDowngrade => canceledAt != null;
  bool get isStarter => tier == 'starter';

  factory PlatformSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return PlatformSubscriptionModel(
      storeId: json['storeId'] as String? ?? '',
      tier: json['tier'] as String? ?? 'starter',
      billingInterval: json['billingInterval'] as String? ?? 'monthly',
      amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'active',
      currentPeriodEnd: json['currentPeriodEnd'] != null ? DateTime.tryParse(json['currentPeriodEnd'] as String) : null,
      nextBillingDate: json['nextBillingDate'] != null ? DateTime.tryParse(json['nextBillingDate'] as String) : null,
      canceledAt: json['canceledAt'] != null ? DateTime.tryParse(json['canceledAt'] as String) : null,
      creditBalanceUSD: (json['creditBalanceUSD'] as num?)?.toDouble() ?? 0,
      posAddon: PosAddonModel.fromJson(json['posAddon'] as Map<String, dynamic>?),
      tierConfig: json['tierConfig'] != null ? PlatformTierModel.fromJson(json['tierConfig'] as Map<String, dynamic>) : null,
      posAddonEligible: json['posAddonEligible'] as bool? ?? false,
      posAddonMonthlyPriceUSD: (json['posAddonMonthlyPriceUSD'] as num?)?.toDouble() ?? 29,
    );
  }
}
