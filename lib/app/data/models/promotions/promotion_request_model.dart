/// Seller-facing paid ad-placement request — `solvexo-api`'s
/// `PromotionRequest` schema (`src/promotions/schemas/promotion-request.schema.ts`).
class PromotionRequestModel {
  final String id;
  final String storeId;
  final String placement; // homepageHero | marketplaceHero | educationHero | categoryHero
  final String creativeUrl;
  final String? mobileCreativeUrl;
  final String? ctaLabel;
  final String linkType; // product | category | external | collection
  final String? linkTarget;
  final String? message;
  final DateTime startAt;
  final DateTime endAt;
  final double priceUSD;
  final Map<String, dynamic> pricingBreakdown;
  final String paymentStatus; // pending | paid | refunded | failed
  final String status; // draft | pending | approved | rejected | active | paused | expired | cancelled
  final String? rejectionReason;
  final String? resultingBannerId;
  final DateTime createdAt;

  const PromotionRequestModel({
    required this.id,
    required this.storeId,
    required this.placement,
    required this.creativeUrl,
    this.mobileCreativeUrl,
    this.ctaLabel,
    required this.linkType,
    this.linkTarget,
    this.message,
    required this.startAt,
    required this.endAt,
    required this.priceUSD,
    required this.pricingBreakdown,
    required this.paymentStatus,
    required this.status,
    this.rejectionReason,
    this.resultingBannerId,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isActive => status == 'active';
  bool get isRejected => status == 'rejected';
  bool get isPaid => paymentStatus == 'paid';

  /// Approved but not yet paid — the only state the "Pay Now" action applies to.
  bool get canPay => status == 'approved' && !isPaid;

  bool get canCancel => ['pending', 'approved', 'active'].contains(status);

  factory PromotionRequestModel.fromJson(Map<String, dynamic> json) => PromotionRequestModel(
        id: json['_id']?.toString() ?? '',
        storeId: json['storeId']?.toString() ?? '',
        placement: json['placement'] as String? ?? '',
        creativeUrl: json['creativeUrl'] as String? ?? '',
        mobileCreativeUrl: json['mobileCreativeUrl'] as String?,
        ctaLabel: json['ctaLabel'] as String?,
        linkType: json['linkType'] as String? ?? 'external',
        linkTarget: json['linkTarget'] as String?,
        message: json['message'] as String?,
        startAt: DateTime.tryParse(json['startAt']?.toString() ?? '') ?? DateTime.now(),
        endAt: DateTime.tryParse(json['endAt']?.toString() ?? '') ?? DateTime.now(),
        priceUSD: (json['priceUSD'] as num?)?.toDouble() ?? 0,
        pricingBreakdown: (json['pricingBreakdown'] as Map?)?.cast<String, dynamic>() ?? const {},
        paymentStatus: json['paymentStatus'] as String? ?? 'pending',
        status: json['status'] as String? ?? 'draft',
        rejectionReason: json['rejectionReason'] as String?,
        resultingBannerId: json['resultingBannerId']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
}

/// Display labels for the 4 shared placements a promotion can target
/// (`src/common/promotion-placements.const.ts`).
const Map<String, String> kPromotionPlacementLabels = {
  'homepageHero': 'Homepage Hero',
  'marketplaceHero': 'Marketplace Hero',
  'educationHero': 'Education Hero',
  'categoryHero': 'Category Hero',
};

String promotionStatusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'Pending Review';
    case 'approved':
      return 'Approved — Pay to Go Live';
    case 'rejected':
      return 'Rejected';
    case 'active':
      return 'Live';
    case 'paused':
      return 'Paused';
    case 'expired':
      return 'Expired';
    case 'cancelled':
      return 'Cancelled';
    default:
      return 'Draft';
  }
}
