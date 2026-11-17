/// On-page SEO metadata embedded on a store/product/category
/// (`solvexo-api`'s `SeoMeta` sub-schema, `src/seo/schemas/seo-meta.schema.ts`).
class SeoMetaModel {
  final String? metaTitle;
  final String? metaDescription;
  final String? ogImage;
  final String? ogTitle;
  final String? ogDescription;
  final String twitterCard;
  final String? canonicalUrlOverride;
  final bool noindex;
  final List<String> keywords;
  final bool aiGenerated;
  final DateTime? updatedAt;

  const SeoMetaModel({
    this.metaTitle,
    this.metaDescription,
    this.ogImage,
    this.ogTitle,
    this.ogDescription,
    this.twitterCard = 'summary_large_image',
    this.canonicalUrlOverride,
    this.noindex = false,
    this.keywords = const [],
    this.aiGenerated = false,
    this.updatedAt,
  });

  factory SeoMetaModel.fromJson(Map<String, dynamic>? json) {
    json ??= const {};
    return SeoMetaModel(
      metaTitle: json['metaTitle'] as String?,
      metaDescription: json['metaDescription'] as String?,
      ogImage: json['ogImage'] as String?,
      ogTitle: json['ogTitle'] as String?,
      ogDescription: json['ogDescription'] as String?,
      twitterCard: json['twitterCard'] as String? ?? 'summary_large_image',
      canonicalUrlOverride: json['canonicalUrlOverride'] as String?,
      noindex: json['noindex'] as bool? ?? false,
      keywords: (json['keywords'] as List? ?? []).cast<String>(),
      aiGenerated: json['aiGenerated'] as bool? ?? false,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
