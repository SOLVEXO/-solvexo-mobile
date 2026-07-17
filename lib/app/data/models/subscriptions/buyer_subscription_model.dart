/// Minimal store info denormalized onto buyer membership responses
/// (`store: { _id, name, logo, slug }`).
class BuyerMembershipStoreModel {
  final String id;
  final String name;
  final String? logo;
  final String? slug;

  const BuyerMembershipStoreModel({
    required this.id,
    required this.name,
    this.logo,
    this.slug,
  });

  factory BuyerMembershipStoreModel.fromJson(Map<String, dynamic> json) {
    return BuyerMembershipStoreModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      slug: json['slug'] as String?,
    );
  }
}

/// Minimal plan info denormalized onto buyer membership responses
/// (`plan: { name, features }` on the list, plus prices on the detail).
class BuyerMembershipPlanInfoModel {
  final String name;
  final List<String> features;
  final double? monthlyPriceUSD;
  final double? yearlyPriceUSD;

  const BuyerMembershipPlanInfoModel({
    required this.name,
    required this.features,
    this.monthlyPriceUSD,
    this.yearlyPriceUSD,
  });

  factory BuyerMembershipPlanInfoModel.fromJson(Map<String, dynamic> json) {
    return BuyerMembershipPlanInfoModel(
      name: json['name'] as String? ?? '',
      features: (json['features'] as List? ?? []).cast<String>(),
      monthlyPriceUSD: (json['monthlyPriceUSD'] as num?)?.toDouble(),
      yearlyPriceUSD: (json['yearlyPriceUSD'] as num?)?.toDouble(),
    );
  }
}

/// One invoice row on the membership detail response (`invoices[]`).
class BuyerMembershipInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String type; // initial | recurring | proration
  final double amountUSD;
  final String status; // paid | failed | pending | refunded | partially_refunded
  final DateTime? paidAt;
  final DateTime? createdAt;

  const BuyerMembershipInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.type,
    required this.amountUSD,
    required this.status,
    this.paidAt,
    this.createdAt,
  });

  factory BuyerMembershipInvoiceModel.fromJson(Map<String, dynamic> json) {
    return BuyerMembershipInvoiceModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      type: json['type'] as String? ?? 'recurring',
      amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      paidAt: _parseDate(json['paidAt']),
      createdAt: _parseDate(json['createdAt']),
    );
  }
}

/// A buyer's store membership (subscription) as returned by
/// `GET api/subscriptions/my` (list rows) and `GET api/subscriptions/my/:id`
/// (detail — additionally carries `invoices`).
class BuyerSubscriptionModel {
  final String id;
  final String planId;
  final String storeId;
  final String billingInterval; // monthly | yearly
  final double amountUSD;
  final String status; // active | paused | canceled | past_due
  final DateTime? startedAt;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? nextBillingDate;
  final DateTime? canceledAt;
  final DateTime? pausedAt;
  final String? cancellationReason;
  final double totalPaidUSD;
  final double creditBalanceUSD;
  final bool pendingCancellation;
  final BuyerMembershipStoreModel? store;
  final BuyerMembershipPlanInfoModel? plan;
  final List<BuyerMembershipInvoiceModel> invoices;

  const BuyerSubscriptionModel({
    required this.id,
    required this.planId,
    required this.storeId,
    required this.billingInterval,
    required this.amountUSD,
    required this.status,
    this.startedAt,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.nextBillingDate,
    this.canceledAt,
    this.pausedAt,
    this.cancellationReason,
    this.totalPaidUSD = 0,
    this.creditBalanceUSD = 0,
    this.pendingCancellation = false,
    this.store,
    this.plan,
    this.invoices = const [],
  });

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCanceled => status == 'canceled';
  bool get isPastDue => status == 'past_due';

  factory BuyerSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return BuyerSubscriptionModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      billingInterval: json['billingInterval'] as String? ?? 'monthly',
      amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'active',
      startedAt: _parseDate(json['startedAt']),
      currentPeriodStart: _parseDate(json['currentPeriodStart']),
      currentPeriodEnd: _parseDate(json['currentPeriodEnd']),
      nextBillingDate: _parseDate(json['nextBillingDate']),
      canceledAt: _parseDate(json['canceledAt']),
      pausedAt: _parseDate(json['pausedAt']),
      cancellationReason: json['cancellationReason'] as String?,
      totalPaidUSD: (json['totalPaidUSD'] as num?)?.toDouble() ?? 0,
      creditBalanceUSD: (json['creditBalanceUSD'] as num?)?.toDouble() ?? 0,
      pendingCancellation: json['pendingCancellation'] as bool? ?? false,
      store: json['store'] is Map<String, dynamic>
          ? BuyerMembershipStoreModel.fromJson(json['store'] as Map<String, dynamic>)
          : null,
      plan: json['plan'] is Map<String, dynamic>
          ? BuyerMembershipPlanInfoModel.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
      invoices: (json['invoices'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(BuyerMembershipInvoiceModel.fromJson)
          .toList(),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
