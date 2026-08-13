import 'package:book_store_app/utils/currency_formatter.dart';

class CouponModel {
  final String id;
  final String code;
  final String discountType; // 'percentage' | 'fixed'
  final double discountValue;
  final double? minOrderAmount;
  final int? usageLimit;
  final int usageCount;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime? createdAt;
  // Only meaningful when discountType == 'fixed' — seller coupons use the
  // issuing store's baseCurrency, platform-scope coupons are always 'USD'.
  final String? currency;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.usageLimit,
    required this.usageCount,
    this.expiresAt,
    required this.isActive,
    this.createdAt,
    this.currency,
  });

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isPercentage => discountType == 'percentage';

  String get discountLabel => isPercentage
      ? '${discountValue.toStringAsFixed(discountValue.truncateToDouble() == discountValue ? 0 : 1)}% off'
      : '${CurrencyFormatter.amount(discountValue, currency)} off';

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      discountType: json['discountType'] as String? ?? 'percentage',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'] as String) : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      currency: json['currency'] as String?,
    );
  }
}
