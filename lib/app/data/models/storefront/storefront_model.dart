/// A seller's public storefront profile — GET /api/store/public/:slug.
class StorefrontModel {
  final String storeId;
  final String sellerId;
  final String name;
  final String slug;
  final String? logo;
  final String? coverImage;
  final String? description;
  final int followersCount;
  final String? sellerType;
  final List<String> badges;

  const StorefrontModel({
    required this.storeId,
    required this.sellerId,
    required this.name,
    required this.slug,
    this.logo,
    this.coverImage,
    this.description,
    required this.followersCount,
    this.sellerType,
    this.badges = const [],
  });

  String get initials => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'S';

  factory StorefrontModel.fromJson(Map<String, dynamic> json) => StorefrontModel(
        storeId: json['storeId'] as String? ?? '',
        sellerId: json['sellerId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        logo: json['logo'] as String?,
        coverImage: json['coverImage'] as String?,
        description: json['description'] as String?,
        followersCount: json['followersCount'] as int? ?? 0,
        sellerType: json['sellerType'] as String?,
        badges: (json['badges'] as List?)?.cast<String>() ?? const [],
      );
}
