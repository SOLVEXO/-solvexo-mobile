/// GET /api/promotions/preview-price — `solvexo-api`'s
/// `PromotionPricingService.computePrice()` return shape.
class PromotionPriceBreakdownModel {
  final String unit; // monthly | weekly | daily | hourly | festival
  final double baseRate;
  final double hours;
  final double weekendFraction;
  final double weekendMultiplierApplied;
  final double peakMultiplierApplied;
  final String? festivalName;
  final double priceUSD;

  const PromotionPriceBreakdownModel({
    required this.unit,
    required this.baseRate,
    required this.hours,
    required this.weekendFraction,
    required this.weekendMultiplierApplied,
    required this.peakMultiplierApplied,
    this.festivalName,
    required this.priceUSD,
  });

  factory PromotionPriceBreakdownModel.fromJson(Map<String, dynamic> json) => PromotionPriceBreakdownModel(
        unit: json['unit'] as String? ?? 'hourly',
        baseRate: (json['baseRate'] as num?)?.toDouble() ?? 0,
        hours: (json['hours'] as num?)?.toDouble() ?? 0,
        weekendFraction: (json['weekendFraction'] as num?)?.toDouble() ?? 0,
        weekendMultiplierApplied: (json['weekendMultiplierApplied'] as num?)?.toDouble() ?? 1,
        peakMultiplierApplied: (json['peakMultiplierApplied'] as num?)?.toDouble() ?? 1,
        festivalName: json['festivalName'] as String?,
        priceUSD: (json['priceUSD'] as num?)?.toDouble() ?? 0,
      );
}
