/// Mirrors `solvexo-api`'s `Rating` schema/`rating.service.ts` responses —
/// used for both the buyer's "My Reviews" list and a product's public
/// review feed (a few fields are only populated in one of the two).
class ReviewComment {
  final String text;
  final DateTime? createdAt;

  const ReviewComment({required this.text, this.createdAt});

  factory ReviewComment.fromJson(Map<String, dynamic> json) => ReviewComment(
        text: json['text'] as String? ?? '',
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );
}

class SellerReply {
  final String text;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SellerReply({required this.text, this.createdAt, this.updatedAt});

  factory SellerReply.fromJson(Map<String, dynamic> json) => SellerReply(
        text: json['text'] as String? ?? '',
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      );
}

class ReviewProductSummary {
  final String productId;
  final String name;
  final String? image;

  const ReviewProductSummary({required this.productId, required this.name, this.image});

  factory ReviewProductSummary.fromJson(Map<String, dynamic> json) => ReviewProductSummary(
        productId: (json['productId'] ?? '').toString(),
        name: json['name'] as String? ?? '',
        image: json['image'] as String?,
      );
}

class ReviewModel {
  final String reviewId;
  final String? productId;
  final ReviewProductSummary? product;
  final String customerName;
  final bool isOwn;
  final double? rating;
  final List<ReviewComment> comments;
  final List<String> media;
  final bool isVerifiedPurchase;
  final SellerReply? sellerReply;
  final bool isFlagged;
  final DateTime? createdAt;

  const ReviewModel({
    required this.reviewId,
    this.productId,
    this.product,
    this.customerName = '',
    this.isOwn = false,
    this.rating,
    this.comments = const [],
    this.media = const [],
    this.isVerifiedPurchase = false,
    this.sellerReply,
    this.isFlagged = false,
    this.createdAt,
  });

  String get commentText => comments.isNotEmpty ? comments.first.text : '';

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        reviewId: (json['reviewId'] ?? json['_id'] ?? '').toString(),
        productId: json['productId']?.toString(),
        product: json['product'] != null ? ReviewProductSummary.fromJson(json['product'] as Map<String, dynamic>) : null,
        customerName: json['customerName'] as String? ??
            (json['customer'] is Map ? (json['customer']['name'] as String? ?? '') : ''),
        isOwn: json['isOwn'] as bool? ?? false,
        rating: (json['rating'] as num?)?.toDouble(),
        comments: (json['comments'] as List?)
                ?.map((c) => ReviewComment.fromJson(c as Map<String, dynamic>))
                .toList() ??
            const [],
        media: (json['media'] as List?)?.cast<String>() ?? const [],
        isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
        sellerReply: json['sellerReply'] != null ? SellerReply.fromJson(json['sellerReply'] as Map<String, dynamic>) : null,
        isFlagged: json['isFlagged'] as bool? ?? false,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );
}

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingBreakdown;

  const ReviewStats({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.ratingBreakdown = const {},
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) => ReviewStats(
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
        totalReviews: json['totalReviews'] as int? ?? 0,
        ratingBreakdown: (json['ratingBreakdown'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v is int ? v : int.tryParse(v.toString()) ?? 0),
            ) ??
            const {},
      );
}
