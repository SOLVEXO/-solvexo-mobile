/// A seller's own free storefront hero carousel entry — `solvexo-api`'s
/// `StoreBanner` schema (`src/store-banner/schemas/store-banner.schema.ts`).
/// Distinct from the paid, shared `Banner` placements a `PromotionRequest`
/// produces once approved+paid.
class StoreBannerModel {
  final String id;
  final String storeId;
  final String type; // hero | promotion | season | collection | video
  final String imageUrl;
  final String? mobileImageUrl;
  final String? ctaLabel;
  final String linkType; // product | category | external | collection
  final String? linkTarget;
  final int order;
  final int priority;
  final String status; // draft | scheduled | active | paused | expired
  final DateTime? startAt;
  final DateTime? endAt;

  const StoreBannerModel({
    required this.id,
    required this.storeId,
    required this.type,
    required this.imageUrl,
    this.mobileImageUrl,
    this.ctaLabel,
    required this.linkType,
    this.linkTarget,
    required this.order,
    required this.priority,
    required this.status,
    this.startAt,
    this.endAt,
  });

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get canResume => status == 'paused' || status == 'expired';

  factory StoreBannerModel.fromJson(Map<String, dynamic> json) => StoreBannerModel(
        id: json['_id']?.toString() ?? '',
        storeId: json['storeId']?.toString() ?? '',
        type: json['type'] as String? ?? 'hero',
        imageUrl: json['imageUrl'] as String? ?? '',
        mobileImageUrl: json['mobileImageUrl'] as String?,
        ctaLabel: json['ctaLabel'] as String?,
        linkType: json['linkType'] as String? ?? 'external',
        linkTarget: json['linkTarget'] as String?,
        order: json['order'] as int? ?? 0,
        priority: json['priority'] as int? ?? 0,
        status: json['status'] as String? ?? 'active',
        startAt: json['startAt'] != null ? DateTime.tryParse(json['startAt'].toString()) : null,
        endAt: json['endAt'] != null ? DateTime.tryParse(json['endAt'].toString()) : null,
      );
}

String storeBannerStatusLabel(String status) {
  switch (status) {
    case 'active':
      return 'Live';
    case 'scheduled':
      return 'Scheduled';
    case 'paused':
      return 'Paused';
    case 'expired':
      return 'Expired';
    default:
      return 'Draft';
  }
}
