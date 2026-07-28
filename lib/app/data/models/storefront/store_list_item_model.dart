/// Sale/promo badge for a store card — present when the seller has an
/// active marketing campaign running for that store right now (platform- or
/// seller-sponsored). Mirrors the shape `StoreService.getPublicStore` and
/// `shapeStoreListItem` both emit on the backend.
class ActiveCampaignBadge {
  final String campaignId;
  final String name;

  /// 'percentage' | 'fixed' | null
  final String? discountType;
  final double? discountValue;
  final DateTime? endDate;

  const ActiveCampaignBadge({
    required this.campaignId,
    required this.name,
    this.discountType,
    this.discountValue,
    this.endDate,
  });

  factory ActiveCampaignBadge.fromJson(Map<String, dynamic> json) {
    return ActiveCampaignBadge(
      campaignId: (json['campaignId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      discountType: json['discountType'] as String?,
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
    );
  }

  /// e.g. "20% OFF" / "$5 OFF" — falls back to "SALE" for a badge-only
  /// campaign with no configured discount.
  String get label {
    if (discountValue != null) {
      if (discountType == 'percentage') {
        return '${discountValue!.toStringAsFixed(0)}% OFF';
      }
      if (discountType == 'fixed') {
        return '\$${discountValue!.toStringAsFixed(0)} OFF';
      }
    }
    return 'SALE';
  }
}

/// A store card shape shared by Home's "Top Stores" row, the Stores browse
/// screen, and search's "Stores" tab — `GET /api/store/public`,
/// `/api/store/public/top`, and `/api/search/stores` all return this shape.
class StoreListItemModel {
  final String storeId;
  final String name;
  final String slug;
  final String? logo;
  final String? coverImage;
  final String? description;
  final String? categoryId;
  final int followersCount;
  final double averageRating;
  final int reviewCount;
  final String? sellerType;
  final List<String> badges;
  final int? productCount;
  final ActiveCampaignBadge? activeCampaign;

  const StoreListItemModel({
    required this.storeId,
    required this.name,
    required this.slug,
    this.logo,
    this.coverImage,
    this.description,
    this.categoryId,
    required this.followersCount,
    required this.averageRating,
    required this.reviewCount,
    this.sellerType,
    this.badges = const [],
    this.productCount,
    this.activeCampaign,
  });

  String get initials =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'S';

  factory StoreListItemModel.fromJson(Map<String, dynamic> json) =>
      StoreListItemModel(
        storeId: json['storeId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        logo: json['logo'] as String?,
        coverImage: json['coverImage'] as String?,
        description: json['description'] as String?,
        categoryId: json['categoryId'] as String?,
        followersCount: json['followersCount'] as int? ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        sellerType: json['sellerType'] as String?,
        badges: (json['badges'] as List?)?.cast<String>() ?? const [],
        productCount: json['productCount'] as int?,
        activeCampaign: json['activeCampaign'] is Map<String, dynamic>
            ? ActiveCampaignBadge.fromJson(
                json['activeCampaign'] as Map<String, dynamic>,
              )
            : null,
      );
}
