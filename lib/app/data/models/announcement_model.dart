/// A currently-active platform announcement — unauthenticated
/// `GET /api/announcements/active?audience=buyers|sellers`. The backend
/// returns up to 5, newest-first; the app shows a single dismissible banner
/// built from the first item.
class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String audience;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.audience,
    required this.status,
    this.scheduledAt,
    this.publishedAt,
    this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      audience: (json['audience'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
