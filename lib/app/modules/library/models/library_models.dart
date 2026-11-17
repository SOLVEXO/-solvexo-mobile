import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';

/// A purchased (or freely availed) digital item, built from the buyer's
/// orders. Only paid orders unlock downloads; unpaid ones (bank transfer
/// awaiting approval) are listed with a status so the buyer knows why.
class LibraryFile {
  LibraryFile({required this.order, required this.item});

  final OrderModel order;
  final OrderItem item;

  String get key => '${order.orderId}:${item.itemId}';
  bool get canDownload => order.isPaid && !order.isCancelled;
  DateTime get purchasedAt => order.paidAt ?? order.createdAt;
}

/// One row of `GET /api/courses/mine`. The response shape was not verified
/// from this environment, so every field is read defensively and blocks are
/// hidden when a value is missing.
class LibraryCourse {
  LibraryCourse({
    required this.id,
    required this.title,
    this.slug,
    this.image,
    this.progress,
    this.lessonsTotal,
    this.lessonsDone,
    this.isPublished = true,
  });

  final String id;
  final String title;
  final String? slug;
  final String? image;

  /// 0..100, or null when the API sends no progress.
  final double? progress;
  final int? lessonsTotal;
  final int? lessonsDone;
  final bool isPublished;

  bool get started => (progress ?? 0) > 0 || (lessonsDone ?? 0) > 0;

  static String? _str(dynamic v) {
    if (v == null || v is Map || v is List) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static LibraryCourse? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final product = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'] as Map)
        : const <String, dynamic>{};
    final course = json['course'] is Map
        ? Map<String, dynamic>.from(json['course'] as Map)
        : const <String, dynamic>{};
    String? pick(String key) =>
        _str(json[key]) ?? _str(course[key]) ?? _str(product[key]);

    final id = pick('_id') ?? pick('id') ?? pick('courseId');
    final title = pick('title') ?? pick('name');
    if (id == null || title == null) return null;

    final images = product['images'] ?? json['images'];
    String? image = pick('thumbnail') ?? pick('coverImage') ?? pick('image');
    if (image == null && images is List && images.isNotEmpty) {
      final first = images.first;
      image = first is Map ? _str(first['url']) : _str(first);
    }

    final p = json['progress'] ?? json['progressPercent'];
    double? progress;
    if (p is num) {
      progress = p.toDouble();
    } else if (p is Map && p['percent'] is num) {
      progress = (p['percent'] as num).toDouble();
    }

    int? asInt(dynamic v) => v is num ? v.toInt() : null;
    final done = json['completedLessons'];

    return LibraryCourse(
      id: id,
      title: title,
      slug: pick('slug'),
      image: image,
      progress: progress?.clamp(0, 100).toDouble(),
      lessonsTotal: asInt(json['totalLessons'] ?? json['lessonsCount']),
      lessonsDone: done is List ? done.length : asInt(done),
      isPublished: json['isPublished'] != false,
    );
  }
}
