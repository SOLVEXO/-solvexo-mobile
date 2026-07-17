/// A single item on the store's SEO checklist
/// (`GET/PATCH /api/store/:storeId/seo/store/checklist`).
///
/// `automated` items (`meta_title_set`, `meta_description_set`, `has_logo`,
/// `has_custom_domain`) are derived server-side and cannot be PATCHed —
/// only `sitemap_submitted`, `search_console_verified`, and
/// `social_profiles_linked` accept manual toggles.
class SeoChecklistItemModel {
  final String key;
  final bool done;
  final bool automated;

  const SeoChecklistItemModel({
    required this.key,
    required this.done,
    required this.automated,
  });

  factory SeoChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return SeoChecklistItemModel(
      key: json['key'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      automated: json['automated'] as bool? ?? false,
    );
  }

  String get label => switch (key) {
        'meta_title_set' => 'Store meta title set',
        'meta_description_set' => 'Store meta description set',
        'has_logo' => 'Store logo uploaded',
        'has_custom_domain' => 'Custom domain connected',
        'sitemap_submitted' => 'Sitemap submitted to search engines',
        'search_console_verified' => 'Search Console verified',
        'social_profiles_linked' => 'Social profiles linked',
        _ => key,
      };
}

/// The seller's SEO overview (`GET /api/store/:storeId/seo/dashboard`).
class SeoDashboardModel {
  final int storeCompleteness;
  final int productCompletenessAvg;
  final int productCount;
  final int checklistCompletion;
  final List<SeoChecklistItemModel> checklist;

  const SeoDashboardModel({
    required this.storeCompleteness,
    required this.productCompletenessAvg,
    required this.productCount,
    required this.checklistCompletion,
    required this.checklist,
  });

  factory SeoDashboardModel.fromJson(Map<String, dynamic> json) {
    return SeoDashboardModel(
      storeCompleteness: json['storeCompleteness'] as int? ?? 0,
      productCompletenessAvg: json['productCompletenessAvg'] as int? ?? 0,
      productCount: json['productCount'] as int? ?? 0,
      checklistCompletion: json['checklistCompletion'] as int? ?? 0,
      checklist: (json['checklist'] as List? ?? [])
          .map((e) => SeoChecklistItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
