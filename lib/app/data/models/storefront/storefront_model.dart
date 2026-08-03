import 'package:book_store_app/app/data/models/store/store_announcement_bar_model.dart';

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
  final double averageRating;
  final int reviewCount;
  final String? sellerType;
  final List<String> badges;
  final List<String> pinnedProductIds;
  final StoreAnnouncementBarModel announcementBar;

  const StorefrontModel({
    required this.storeId,
    required this.sellerId,
    required this.name,
    required this.slug,
    this.logo,
    this.coverImage,
    this.description,
    required this.followersCount,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.sellerType,
    this.badges = const [],
    this.pinnedProductIds = const [],
    this.announcementBar = const StoreAnnouncementBarModel(),
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
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        sellerType: json['sellerType'] as String?,
        badges: (json['badges'] as List?)?.cast<String>() ?? const [],
        pinnedProductIds: (json['pinnedProductIds'] as List?)?.cast<String>() ?? const [],
        announcementBar: json['announcementBar'] is Map<String, dynamic>
            ? StoreAnnouncementBarModel.fromJson(json['announcementBar'] as Map<String, dynamic>)
            : const StoreAnnouncementBarModel(),
      );
}
