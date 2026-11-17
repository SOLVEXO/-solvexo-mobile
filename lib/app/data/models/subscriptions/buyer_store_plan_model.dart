/// A single structured benefit attached to a store membership plan, as
/// returned by `GET api/subscriptions/public/:storeId/plans` (`benefits[]`).
/// One flat shape covering every benefit type's optional config — mirrors the
/// backend's `PlanBenefitDto`.
class BuyerPlanBenefitModel {
  final String type; // discount | shipping | early_access | loyalty_multiplier | credits | priority_support | priority_booking
  final bool enabled;
  final String? label;

  // discount
  final String? scope; // store | category | product
  final double? discountPercent;
  final double? maxDiscountAmountUSD;
  final double? minOrderValueUSD;

  // shipping
  final String? shippingType; // free | discounted
  final double? shippingDiscountPercent;
  final double? minOrderValueForShippingUSD;

  // early access
  final int? earlyAccessHours;

  // loyalty multiplier
  final double? multiplier;

  // credits
  final double? creditsPerCycle;
  final String? creditType; // download | service

  const BuyerPlanBenefitModel({
    required this.type,
    this.enabled = true,
    this.label,
    this.scope,
    this.discountPercent,
    this.maxDiscountAmountUSD,
    this.minOrderValueUSD,
    this.shippingType,
    this.shippingDiscountPercent,
    this.minOrderValueForShippingUSD,
    this.earlyAccessHours,
    this.multiplier,
    this.creditsPerCycle,
    this.creditType,
  });

  factory BuyerPlanBenefitModel.fromJson(Map<String, dynamic> json) {
    return BuyerPlanBenefitModel(
      type: json['type'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      label: json['label'] as String?,
      scope: json['scope'] as String?,
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      maxDiscountAmountUSD: (json['maxDiscountAmountUSD'] as num?)?.toDouble(),
      minOrderValueUSD: (json['minOrderValueUSD'] as num?)?.toDouble(),
      shippingType: json['shippingType'] as String?,
      shippingDiscountPercent: (json['shippingDiscountPercent'] as num?)?.toDouble(),
      minOrderValueForShippingUSD: (json['minOrderValueForShippingUSD'] as num?)?.toDouble(),
      earlyAccessHours: (json['earlyAccessHours'] as num?)?.toInt(),
      multiplier: (json['multiplier'] as num?)?.toDouble(),
      creditsPerCycle: (json['creditsPerCycle'] as num?)?.toDouble(),
      creditType: json['creditType'] as String?,
    );
  }

  /// Human-readable bullet derived from the structured config. Falls back to
  /// the seller's custom marketing [label] when one is set.
  String get summary {
    if (label != null && label!.trim().isNotEmpty) return label!;
    switch (type) {
      case 'discount':
        final pct = discountPercent?.toStringAsFixed(0) ?? '';
        switch (scope) {
          case 'category':
            return 'Save $pct% on select categories';
          case 'product':
            return 'Save $pct% on select products';
          default:
            return 'Save $pct% storewide';
        }
      case 'shipping':
        if (shippingType == 'free') return 'Free shipping';
        final pct = shippingDiscountPercent?.toStringAsFixed(0) ?? '';
        return '$pct% off shipping';
      case 'early_access':
        return earlyAccessHours != null ? '${earlyAccessHours}h early access to new products' : 'Early access to new products';
      case 'loyalty_multiplier':
        final x = multiplier ?? 1;
        return '${x == x.roundToDouble() ? x.toStringAsFixed(0) : x}x loyalty points';
      case 'credits':
        final count = creditsPerCycle ?? 0;
        final formatted = count == count.roundToDouble() ? count.toStringAsFixed(0) : count.toString();
        return creditType == 'service' ? '$formatted service credits per cycle' : '$formatted download credits per cycle';
      case 'priority_support':
        return 'Priority support';
      case 'priority_booking':
        return 'Priority booking';
      default:
        return type;
    }
  }
}

/// An active membership plan a buyer can subscribe to, as returned by the
/// public `GET api/subscriptions/public/:storeId/plans` endpoint.
class BuyerStorePlanModel {
  final String id;
  final String name;
  final String? description;
  final double monthlyPriceUSD;
  final double? yearlyPriceUSD;
  final List<String> features;
  final List<BuyerPlanBenefitModel> benefits;
  final String displayCurrency;
  final double displayMonthlyPrice;
  final double? displayYearlyPrice;

  const BuyerStorePlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.monthlyPriceUSD,
    this.yearlyPriceUSD,
    required this.features,
    required this.benefits,
    required this.displayCurrency,
    required this.displayMonthlyPrice,
    this.displayYearlyPrice,
  });

  factory BuyerStorePlanModel.fromJson(Map<String, dynamic> json) {
    return BuyerStorePlanModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      monthlyPriceUSD: (json['monthlyPriceUSD'] as num?)?.toDouble() ?? 0,
      yearlyPriceUSD: (json['yearlyPriceUSD'] as num?)?.toDouble(),
      features: (json['features'] as List? ?? []).cast<String>(),
      benefits: (json['benefits'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(BuyerPlanBenefitModel.fromJson)
          .toList(),
      displayCurrency: json['displayCurrency'] as String? ?? 'USD',
      displayMonthlyPrice: (json['displayMonthlyPrice'] as num?)?.toDouble() ?? (json['monthlyPriceUSD'] as num?)?.toDouble() ?? 0,
      displayYearlyPrice: (json['displayYearlyPrice'] as num?)?.toDouble(),
    );
  }

  /// Enabled benefits only — what the storefront renders as bullets.
  List<BuyerPlanBenefitModel> get activeBenefits => benefits.where((b) => b.enabled).toList();
}
