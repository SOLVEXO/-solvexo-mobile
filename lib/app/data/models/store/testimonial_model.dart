/// Buyer-facing, unauthenticated homepage testimonial — server-cached
/// `GET /api/store/public/testimonials?limit=`. Sourced from real seller/
/// store reviews on the backend, never invented copy.
class TestimonialModel {
  final String id;

  /// Seller/store display name, or "Verified Buyer" when anonymized.
  final String name;
  final String? storeName;

  /// 4-5 (backend only surfaces high-rated reviews here).
  final int rating;
  final String text;
  final bool isVerifiedPurchase;

  const TestimonialModel({
    required this.id,
    required this.name,
    this.storeName,
    required this.rating,
    required this.text,
    this.isVerifiedPurchase = false,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    return TestimonialModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Verified Buyer').toString(),
      storeName: json['storeName'] as String?,
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      text: (json['text'] ?? '').toString(),
      isVerifiedPurchase: json['isVerifiedPurchase'] == true,
    );
  }
}
