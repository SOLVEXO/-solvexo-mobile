import 'package:book_store_app/app/data/models/seo/seo_meta_model.dart';

/// One row of `GET /api/store/:storeId/seo/products` (paginated).
class SeoProductListItemModel {
  final String id;
  final String name;
  final String slug;
  final SeoMetaModel seo;
  final int completeness;

  const SeoProductListItemModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.seo,
    required this.completeness,
  });

  factory SeoProductListItemModel.fromJson(Map<String, dynamic> json) {
    return SeoProductListItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      seo: SeoMetaModel.fromJson(json['seo'] as Map<String, dynamic>?),
      completeness: json['completeness'] as int? ?? 0,
    );
  }

  SeoProductListItemModel copyWith({SeoMetaModel? seo}) {
    return SeoProductListItemModel(
      id: id,
      name: name,
      slug: slug,
      seo: seo ?? this.seo,
      completeness: completeness,
    );
  }
}
