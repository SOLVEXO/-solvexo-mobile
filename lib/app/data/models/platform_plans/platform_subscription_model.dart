import 'package:book_store_app/app/data/models/platform_plans/platform_plan_model.dart';

/// The seller's own platform-plan subscription for one store — mirrors the
/// merged `PlatformPlanSubscription` schema, served by
/// `GET /api/platform-plans/:storeId` (subscription fields + full `plan`).
class PlatformSubscriptionModel {
  final String id;
  final String storeId;
  final String billingInterval; // 'monthly' | 'yearly'
  final double amountUSD;
  final String status; // 'trialing' | 'active' | 'past_due' | 'canceled'
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;
  final DateTime? nextBillingDate;
  final DateTime? canceledAt;
  final double totalPaidUSD;
  final double creditBalanceUSD;
  final PlatformPlanModel? plan;

  const PlatformSubscriptionModel({
    required this.id,
    required this.storeId,
    required this.billingInterval,
    required this.amountUSD,
    required this.status,
    this.trialEndsAt,
    this.currentPeriodEnd,
    this.nextBillingDate,
    this.canceledAt,
    required this.totalPaidUSD,
    required this.creditBalanceUSD,
    this.plan,
  });

  bool get isTrialing => status == 'trialing';
  bool get isPastDue => status == 'past_due';
  bool get isFreePlan => plan?.isFree ?? true;

  static DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

  factory PlatformSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return PlatformSubscriptionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      storeId: (json['storeId'] ?? '').toString(),
      billingInterval: json['billingInterval'] as String? ?? 'monthly',
      amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'active',
      trialEndsAt: _date(json['trialEndsAt']),
      currentPeriodEnd: _date(json['currentPeriodEnd']),
      nextBillingDate: _date(json['nextBillingDate']),
      canceledAt: _date(json['canceledAt']),
      totalPaidUSD: (json['totalPaidUSD'] as num?)?.toDouble() ?? 0,
      creditBalanceUSD: (json['creditBalanceUSD'] as num?)?.toDouble() ?? 0,
      plan: json['plan'] != null ? PlatformPlanModel.fromJson(json['plan'] as Map<String, dynamic>) : null,
    );
  }
}
