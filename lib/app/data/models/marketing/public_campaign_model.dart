/// Buyer-facing, unauthenticated view of a currently-active platform
/// marketing campaign — `GET /api/public/marketing/campaigns`. Distinct from
/// the seller-side join/leave `CampaignModel` (`campaign_model.dart`, which
/// carries `isJoined`/`participatingStoreIds`) — buyers only ever browse.
class PublicCampaignModel {
  final String id;
  final String name;
  final String description;
  final String? bannerImage;
  final DateTime? endDate;

  /// 'percentage' | 'fixed' | null
  final String? discountType;
  final double? discountValue;
  final int storeCount;

  const PublicCampaignModel({
    required this.id,
    required this.name,
    required this.description,
    this.bannerImage,
    this.endDate,
    this.discountType,
    this.discountValue,
    this.storeCount = 0,
  });

  factory PublicCampaignModel.fromJson(Map<String, dynamic> json) {
    return PublicCampaignModel(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      bannerImage: json['bannerImage'] as String?,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      discountType: json['discountType'] as String?,
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      storeCount: (json['storeCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// e.g. "20% OFF" / "$5 OFF" — null when the campaign has no configured
  /// discount (some campaigns are purely promotional/visibility-only).
  String? get discountLabel {
    if (discountValue == null) return null;
    if (discountType == 'percentage') {
      return '${discountValue!.toStringAsFixed(0)}% OFF';
    }
    if (discountType == 'fixed') {
      return '\$${discountValue!.toStringAsFixed(0)} OFF';
    }
    return null;
  }
}
