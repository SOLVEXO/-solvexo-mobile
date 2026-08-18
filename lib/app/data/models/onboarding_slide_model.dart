/// A first-launch intro slide managed by the admin — unauthenticated
/// `GET /api/onboarding-slides`. The backend returns only active slides,
/// sorted by `order`.
class OnboardingSlideModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final int order;

  const OnboardingSlideModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.order,
  });

  factory OnboardingSlideModel.fromJson(Map<String, dynamic> json) {
    return OnboardingSlideModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      order: json['order'] as int? ?? 0,
    );
  }
}
