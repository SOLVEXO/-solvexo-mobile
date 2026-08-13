import 'package:book_store_app/utils/currency_formatter.dart';

class CampaignModel {
  final String id;
  final String name;
  final String? description;
  final String? bannerImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String? discountType; // 'percentage' | 'fixed'
  final double? discountValue;
  final List<String> participatingStoreIds;
  final bool isJoined;

  /// 'seller' (opt-in, default) | 'platform' (auto-applies to every store —
  /// join/leave are rejected server-side, see [isPlatformSponsored]).
  final String sponsorType;

  /// Only meaningful when discountType == 'fixed' — campaigns are always
  /// platform-wide, so this is always 'USD' (backend defaults it to 'USD').
  final String currency;

  const CampaignModel({
    required this.id,
    required this.name,
    this.description,
    this.bannerImage,
    this.startDate,
    this.endDate,
    required this.status,
    this.discountType,
    this.discountValue,
    this.participatingStoreIds = const [],
    this.isJoined = false,
    this.sponsorType = 'seller',
    this.currency = 'USD',
  });

  bool get hasDiscount => discountType != null && discountValue != null;
  bool get isPercentage => discountType == 'percentage';
  bool get isPlatformSponsored => sponsorType == 'platform';

  String get discountLabel {
    final value = discountValue ?? 0;
    return isPercentage
        ? '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}% OFF'
        : '${CurrencyFormatter.amount(value, currency, decimals: value.truncateToDouble() == value ? 0 : 2)} OFF';
  }

  bool get isEnded => endDate != null && endDate!.isBefore(DateTime.now());

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      bannerImage: json['bannerImage'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'] as String) : null,
      status: json['status'] as String? ?? 'active',
      discountType: json['discountType'] as String?,
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      participatingStoreIds: (json['participatingStoreIds'] as List?)?.cast<String>() ?? const [],
      isJoined: json['isJoined'] as bool? ?? false,
      sponsorType: json['sponsorType'] as String? ?? 'seller',
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  CampaignModel copyWith({bool? isJoined}) {
    return CampaignModel(
      id: id,
      name: name,
      description: description,
      bannerImage: bannerImage,
      startDate: startDate,
      endDate: endDate,
      status: status,
      discountType: discountType,
      discountValue: discountValue,
      participatingStoreIds: participatingStoreIds,
      isJoined: isJoined ?? this.isJoined,
      sponsorType: sponsorType,
      currency: currency,
    );
  }
}
