/// Resolved discount benefit on the benefits summary.
class BuyerBenefitDiscountModel {
  final String? scope; // store | category | product
  final double? discountPercent;
  final String? label;

  const BuyerBenefitDiscountModel({this.scope, this.discountPercent, this.label});

  factory BuyerBenefitDiscountModel.fromJson(Map<String, dynamic> json) {
    return BuyerBenefitDiscountModel(
      scope: json['scope'] as String?,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      label: json['label'] as String?,
    );
  }
}

/// Resolved shipping benefit on the benefits summary.
class BuyerBenefitShippingModel {
  final bool free;
  final double discountPercent;
  final double? minOrderValueForShippingUSD;

  const BuyerBenefitShippingModel({
    required this.free,
    required this.discountPercent,
    this.minOrderValueForShippingUSD,
  });

  factory BuyerBenefitShippingModel.fromJson(Map<String, dynamic> json) {
    return BuyerBenefitShippingModel(
      free: json['free'] as bool? ?? false,
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
      minOrderValueForShippingUSD: (json['minOrderValueForShippingUSD'] as num?)?.toDouble(),
    );
  }
}

/// Credit balance line on the benefits summary (`credits[]`).
class BuyerBenefitCreditModel {
  final String creditType; // download | service
  final double balance;
  final double totalGranted;

  const BuyerBenefitCreditModel({
    required this.creditType,
    required this.balance,
    required this.totalGranted,
  });

  factory BuyerBenefitCreditModel.fromJson(Map<String, dynamic> json) {
    return BuyerBenefitCreditModel(
      creditType: json['creditType'] as String? ?? 'download',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      totalGranted: (json['totalGranted'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// A buyer's active membership benefits at one store, as returned by
/// `GET api/subscriptions/my/benefits/:storeId`. When `subscribed` is false
/// every other field is absent.
class BuyerStoreBenefitsModel {
  final bool subscribed;
  final String? planName;
  final BuyerBenefitDiscountModel? discount;
  final BuyerBenefitShippingModel? shipping;
  final double loyaltyMultiplier;
  final int? earlyAccessHours;
  final bool hasPrioritySupport;
  final bool hasPriorityBooking;
  final List<BuyerBenefitCreditModel> credits;

  const BuyerStoreBenefitsModel({
    required this.subscribed,
    this.planName,
    this.discount,
    this.shipping,
    this.loyaltyMultiplier = 1,
    this.earlyAccessHours,
    this.hasPrioritySupport = false,
    this.hasPriorityBooking = false,
    this.credits = const [],
  });

  static const empty = BuyerStoreBenefitsModel(subscribed: false);

  factory BuyerStoreBenefitsModel.fromJson(Map<String, dynamic> json) {
    return BuyerStoreBenefitsModel(
      subscribed: json['subscribed'] as bool? ?? false,
      planName: json['planName'] as String?,
      discount: json['discount'] is Map<String, dynamic>
          ? BuyerBenefitDiscountModel.fromJson(json['discount'] as Map<String, dynamic>)
          : null,
      shipping: json['shipping'] is Map<String, dynamic>
          ? BuyerBenefitShippingModel.fromJson(json['shipping'] as Map<String, dynamic>)
          : null,
      loyaltyMultiplier: (json['loyaltyMultiplier'] as num?)?.toDouble() ?? 1,
      earlyAccessHours: (json['earlyAccessHours'] as num?)?.toInt(),
      hasPrioritySupport: json['hasPrioritySupport'] as bool? ?? false,
      hasPriorityBooking: json['hasPriorityBooking'] as bool? ?? false,
      credits: (json['credits'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(BuyerBenefitCreditModel.fromJson)
          .toList(),
    );
  }
}
