import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

// Course player (B1) and certificates (B2). Shapes from backend 5adba44
// (src/classroom courses.service.ts) and live calls as the test buyer
// (2026-11-20).

class CourseLessonRef {
  const CourseLessonRef({required this.id, required this.title, required this.type, this.durationMinutes});
  final String id, title, type; // video | pdf | text | quiz
  final int? durationMinutes;
}

class CourseSectionRef {
  const CourseSectionRef({required this.title, required this.lessons});
  final String title;
  final List<CourseLessonRef> lessons;
}

/// GET /api/courses/learn/:idOrSlug
class LearnCourse {
  const LearnCourse({
    required this.productId,
    required this.name,
    required this.slug,
    required this.sections,
    required this.completed,
    this.image,
    this.storeName,
    this.lastLessonId,
    this.completedAt,
    this.certificateCode,
    this.certificateEnabled = false,
    this.certificateDetailsRequired = false,
    this.accessExpiresAt,
    this.instructor,
    this.outcomes = const [],
  });

  final String productId, name, slug;
  final String? image, storeName, lastLessonId, certificateCode, instructor;
  final List<CourseSectionRef> sections;
  final Set<String> completed;
  final DateTime? completedAt, accessExpiresAt;
  final bool certificateEnabled, certificateDetailsRequired;
  final List<String> outcomes;

  List<CourseLessonRef> get lessons => [for (final s in sections) ...s.lessons];
  int get percent => lessons.isEmpty ? 0 : (completed.where((id) => lessons.any((l) => l.id == id)).length * 100 / lessons.length).round();
  bool get isFinished => lessons.isNotEmpty && lessons.every((l) => completed.contains(l.id));

  factory LearnCourse.fromJson(Map j) {
    final p = j['product'] is Map ? j['product'] as Map : const {};
    final prog = j['progress'] is Map ? j['progress'] as Map : const {};
    final ins = j['instructor'] is Map ? j['instructor'] as Map : const {};
    DateTime? t(dynamic v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();
    return LearnCourse(
      productId: '${p['_id'] ?? ''}',
      name: '${p['name'] ?? ''}',
      slug: '${p['slug'] ?? ''}',
      image: p['image'] as String?,
      storeName: p['storeName'] as String?,
      sections: [
        for (final s in (j['sections'] as List? ?? const []).whereType<Map>())
          CourseSectionRef(title: '${s['title'] ?? ''}', lessons: [
            for (final l in (s['lessons'] as List? ?? const []).whereType<Map>())
              CourseLessonRef(
                id: '${l['_id']}',
                title: '${l['title'] ?? ''}',
                type: '${l['type'] ?? 'video'}',
                durationMinutes: (l['durationMinutes'] as num?)?.toInt(),
              ),
          ]),
      ],
      completed: {for (final id in (prog['completedLessonIds'] as List? ?? const [])) '$id'},
      lastLessonId: prog['lastLessonId'] as String?,
      completedAt: t(prog['completedAt']),
      certificateCode: prog['certificateCode'] as String?,
      certificateEnabled: j['certificateEnabled'] == true,
      certificateDetailsRequired: j['certificateDetailsRequired'] == true,
      accessExpiresAt: t(j['accessExpiresAt']),
      instructor: (ins['name'] as String?)?.trim().isEmpty == true ? null : ins['name'] as String?,
      outcomes: (j['outcomes'] as List?)?.map((e) => '$e').toList() ?? const [],
    );
  }
}

/// GET /api/courses/learn/:idOrSlug/lessons/:lessonId. Uploaded files come
/// as a signed URL valid for 1 h (`media.kind == 'file'`); YouTube / Vimeo
/// as `media.kind == 'external'`.
class LessonContent {
  const LessonContent({required this.id, required this.title, required this.type, this.text = '', this.mediaKind, this.url, this.mimeType});
  final String id, title, type, text;
  final String? mediaKind, url, mimeType;

  bool get isNativeVideo => type == 'video' && mediaKind == 'file' && url != null;
  bool get isExternalVideo => type == 'video' && mediaKind == 'external' && url != null;

  factory LessonContent.fromJson(Map j) {
    final m = j['media'] is Map ? j['media'] as Map : const {};
    final f = j['file'] is Map ? j['file'] as Map : const {};
    return LessonContent(
      id: '${j['_id']}',
      title: '${j['title'] ?? ''}',
      type: '${j['type'] ?? 'video'}',
      text: '${j['text'] ?? ''}',
      mediaKind: m['kind'] as String?,
      url: (m['url'] ?? j['videoUrl'] ?? f['url']) as String?,
      mimeType: f['mimeType'] as String?,
    );
  }

  /// YouTube / Vimeo page URL -> embeddable player URL, else null.
  static String? embedUrl(String raw) {
    final u = Uri.tryParse(raw);
    if (u == null) return null;
    final h = u.host.toLowerCase();
    String? id;
    if (h.endsWith('youtu.be')) id = u.pathSegments.isEmpty ? null : u.pathSegments.first;
    if (h.contains('youtube.com')) {
      id = u.queryParameters['v'] ?? (u.pathSegments.length > 1 && ['embed', 'shorts', 'live'].contains(u.pathSegments.first) ? u.pathSegments[1] : null);
    }
    if (id != null && id.isNotEmpty) return 'https://www.youtube.com/embed/$id?playsinline=1&rel=0';
    if (h.contains('vimeo.com')) {
      final vid = u.pathSegments.lastWhere((s) => RegExp(r'^\d+$').hasMatch(s), orElse: () => '');
      if (vid.isNotEmpty) return 'https://player.vimeo.com/video/$vid';
    }
    return null;
  }
}

/// Certificate (public verify shape, GET /api/courses/certificates/:code).
class CourseCertificate {
  const CourseCertificate({required this.code, required this.learnerName, required this.courseName, this.raw = const {}});
  final String code, learnerName, courseName;
  final Map<String, dynamic> raw;

  String? s(String k) {
    final v = raw[k];
    return v is String && v.trim().isNotEmpty ? v : null;
  }

  Map get config => raw['config'] is Map ? raw['config'] as Map : const {};
  String? c(String k) {
    final v = config[k];
    return v is String && v.trim().isNotEmpty ? v : null;
  }

  DateTime? get issuedAt => DateTime.tryParse('${raw['issuedAt'] ?? raw['completedAt'] ?? ''}')?.toLocal();

  factory CourseCertificate.fromJson(Map j) => CourseCertificate(
        code: '${j['code'] ?? ''}',
        learnerName: '${j['learnerName'] ?? ''}',
        courseName: '${j['courseName'] ?? j['courseTitle'] ?? ''}',
        raw: Map<String, dynamic>.from(j),
      );
}

class CourseRepository {
  CourseRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  Map _data(Response r) => (r.data as Map)['data'] as Map;

  /// Throws on failure (the screen shows Retry).
  Future<LearnCourse> learn(String idOrSlug) async =>
      LearnCourse.fromJson(_data(await _client.get(ApiConstants.courseLearn(idOrSlug), requiresAuth: true)));

  Future<LessonContent> lesson(String idOrSlug, String lessonId) async =>
      LessonContent.fromJson(_data(await _client.get(ApiConstants.courseLesson(idOrSlug, lessonId), requiresAuth: true)));

  /// Returns the server's completedLessonIds / certificate state, or an error message.
  Future<({Map? data, String? error})> complete(String idOrSlug, String lessonId) async {
    try {
      final r = await _client.post(ApiConstants.courseLessonComplete(idOrSlug, lessonId), requiresAuth: true);
      final b = r.data is Map ? r.data as Map : const {};
      return (data: b['data'] is Map ? b['data'] as Map : b, error: null);
    } on DioException catch (e) {
      return (data: null, error: ApiError.fromDio(e) ?? 'Could not save your progress.');
    }
  }

  Future<({String? code, String? error})> saveCertificateDetails(String idOrSlug, Map<String, String> details) async {
    try {
      final r = await _client.post(ApiConstants.courseCertificateDetails(idOrSlug), data: details, requiresAuth: true);
      final d = (r.data as Map)['data'];
      return (code: d is Map ? d['certificateCode'] as String? : null, error: null);
    } on DioException catch (e) {
      return (code: null, error: ApiError.fromDio(e) ?? 'Could not save your details.');
    }
  }

  /// Public. Throws on failure; a 404 means "not a valid certificate".
  Future<CourseCertificate> certificate(String code) async =>
      CourseCertificate.fromJson(_data(await _client.get(ApiConstants.courseCertificate(code))));
}
