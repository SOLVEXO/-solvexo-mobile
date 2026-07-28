/// A watermarked/trimmed preview derivative of a digital product's source
/// file — never the original file. Mirrors the response shape of
/// `GET /api/products/preview/:id` (see solvexo-api ProductsService.getProductPreview).
class ProductPreviewModel {
  final String type; // 'image' | 'pdf' | 'video' | 'audio'
  final String? url; // image / video / audio
  final List<String> pages; // pdf only — one signed image URL per page
  final int expiresAt; // unix seconds — url(s) stop working after this

  ProductPreviewModel({
    required this.type,
    this.url,
    this.pages = const [],
    required this.expiresAt,
  });

  factory ProductPreviewModel.fromJson(Map<String, dynamic> json) {
    return ProductPreviewModel(
      type: json['type'] as String? ?? '',
      url: json['url'] as String?,
      pages: (json['pages'] as List? ?? []).cast<String>(),
      expiresAt: json['expiresAt'] as int? ?? 0,
    );
  }
}
