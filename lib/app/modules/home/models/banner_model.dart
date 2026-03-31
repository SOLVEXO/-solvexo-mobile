class BannerModel {
  final String id;
  final String imageUrl;
  final String publicId;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.publicId,
    required this.isActive,
    required this.order,
    this.createdAt,
  });

  // ✅ Matches your NestJS response: { _id, imageUrl, publicId, isActive, order }
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      publicId: json['publicId']?.toString() ?? '',
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
