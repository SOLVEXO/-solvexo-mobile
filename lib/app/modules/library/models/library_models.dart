/// A purchased (or freely availed) digital item. Only paid orders unlock
/// downloads; unpaid ones (bank transfer awaiting approval) are listed with
/// a status so the buyer knows why.
/// One row of `GET /api/orders/my-library` (backend 5adba44
/// orders.service.ts getMyLibrary; live 2026-11-18): {orderId, orderNumber,
/// itemId, productId, name, image, licenseType, storeId, isPaid,
/// purchasedAt, paidAt, downloadCount, reviewable, slug, category,
/// subCategory, curricula, fileCount, fileTypes, totalSize, unavailable:
/// null|removed|expired, expiresAt, deliveryFormat: download|course,
/// storeName, storeSlug}. One row per product; cancelled/refunded items are
/// already left out by the server.
class LibraryFile {
  LibraryFile({
    required this.orderId,
    required this.orderNumber,
    required this.itemId,
    required this.productId,
    required this.name,
    required this.purchasedAt,
    this.image,
    this.storeName,
    this.isPaid = false,
    this.downloadCount = 0,
    this.unavailable,
    this.expiresAt,
    this.deliveryFormat = 'download',
    this.fileCount = 0,
    this.fileTypes = const [],
  });

  final String orderId;
  final String orderNumber;
  final String itemId;
  final String productId;
  final String name;
  final String? image;
  final String? storeName;
  final bool isPaid;
  final DateTime purchasedAt;
  final int downloadCount;

  /// removed (admin takedown / product gone) | expired (link window over).
  final String? unavailable;
  final DateTime? expiresAt;
  final String deliveryFormat;
  final int fileCount;
  final List<String> fileTypes;

  bool get available => unavailable == null;
  bool get isCourse => deliveryFormat == 'course';
  String get key => '$orderId:$itemId';
  bool get canDownload => available && isPaid;

  factory LibraryFile.fromJson(Map j) {
    DateTime? t(dynamic v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();
    return LibraryFile(
      orderId: '${j['orderId'] ?? ''}',
      orderNumber: '${j['orderNumber'] ?? ''}',
      itemId: '${j['itemId'] ?? ''}',
      productId: '${j['productId'] ?? ''}',
      name: '${j['name'] ?? ''}',
      image: j['image'] as String?,
      storeName: j['storeName'] as String?,
      isPaid: j['isPaid'] == true,
      purchasedAt: t(j['paidAt']) ?? t(j['purchasedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      downloadCount: (j['downloadCount'] as num?)?.toInt() ?? 0,
      unavailable: j['unavailable'] as String?,
      expiresAt: t(j['expiresAt']),
      deliveryFormat: '${j['deliveryFormat'] ?? 'download'}',
      fileCount: (j['fileCount'] as num?)?.toInt() ?? 0,
      fileTypes: (j['fileTypes'] as List?)?.map((e) => '$e').toList() ?? const [],
    );
  }
}

/// One row of `GET /api/courses/mine`. Live shape (verified 2026-11-17):
/// `{productId, name, slug, image, deliveryFormat, lessons, completed,
/// completedAt, certificateCode, percent, lastLessonId, accessExpiresAt,
/// accessExpired, isPublished}`. Older/nested shapes are still read; blocks
/// are hidden when a value is missing.
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
    this.accessExpired = false,
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

  /// The buyer's access window (purchase date + accessDays) has ended.
  final bool accessExpired;

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

    final id =
        pick('productId') ?? pick('_id') ?? pick('id') ?? pick('courseId');
    final title = pick('title') ?? pick('name');
    if (id == null || title == null) return null;

    final images = product['images'] ?? json['images'];
    String? image = pick('thumbnail') ?? pick('coverImage') ?? pick('image');
    if (image == null && images is List && images.isNotEmpty) {
      final first = images.first;
      image = first is Map ? _str(first['url']) : _str(first);
    }

    final p = json['percent'] ?? json['progress'] ?? json['progressPercent'];
    double? progress;
    if (p is num) {
      progress = p.toDouble();
    } else if (p is Map && p['percent'] is num) {
      progress = (p['percent'] as num).toDouble();
    }

    int? asInt(dynamic v) => v is num ? v.toInt() : null;
    final done = json['completed'] ?? json['completedLessons'];

    return LibraryCourse(
      id: id,
      title: title,
      slug: pick('slug'),
      image: image,
      progress: progress?.clamp(0, 100).toDouble(),
      lessonsTotal:
          asInt(json['lessons'] ?? json['totalLessons'] ?? json['lessonsCount']),
      lessonsDone: done is List ? done.length : asInt(done),
      isPublished: json['isPublished'] != false,
      accessExpired: json['accessExpired'] == true,
    );
  }
}
