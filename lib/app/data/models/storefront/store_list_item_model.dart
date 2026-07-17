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
  });

  String get initials => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'S';

  factory StoreListItemModel.fromJson(Map<String, dynamic> json) => StoreListItemModel(
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
      );
}
