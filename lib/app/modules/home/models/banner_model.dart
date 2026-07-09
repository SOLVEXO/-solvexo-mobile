class BannerModel {
  final String id;
  final String imageUrl;
  final String publicId;
  final String? urlOnTap;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.publicId,
    this.urlOnTap,
    required this.isActive,
    required this.order,
    this.createdAt,
  });

  // ✅ Matches the real NestJS response: { _id, bannerImage, publicId,
  // urlOnTap, isActive, order } — note the image field is `bannerImage`,
  // not `imageUrl`.
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id']?.toString() ?? '',
      imageUrl: json['bannerImage']?.toString() ?? '',
      publicId: json['publicId']?.toString() ?? '',
      urlOnTap: json['urlOnTap']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  // Convenience getter — your carousel uses item.image
  String get image => imageUrl;

  @override
  String toString() => 'BannerModel(id: $id, imageUrl: $imageUrl)';
}
