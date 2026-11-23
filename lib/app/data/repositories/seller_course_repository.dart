import 'dart:io';

import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/network/dio_service.dart';
import 'package:book_store_app/utils/upload_rules.dart';
import 'package:dio/dio.dart';

// Course builder (docs 6.3 "Course builder"; checklist #14a). Shapes and
// limits from real calls on the test draft (2026-11-18), see the commit.

/// Lesson. New lessons are video only: an uploaded private video
/// (`file: {url: <publicId>, name, size, mimeType}`) or an https
/// YouTube/Vimeo `videoUrl`. Older pdf / text / quiz lessons are kept as
/// they are (sent back unchanged) so they keep playing.
class CourseLesson {
  CourseLesson({
    this.id,
    required this.title,
    this.type = 'video',
    this.file,
    this.videoUrl,
    this.durationMinutes,
    this.isPreview = false,
    Map<String, dynamic>? raw,
  }) : raw = raw ?? const {};

  final String? id;
  String title;
  final String type; // video | pdf | text | quiz
  Map<String, dynamic>? file;
  String? videoUrl;
  int? durationMinutes;
  bool isPreview;

  /// Everything the server sent, so legacy lessons go back untouched.
  final Map<String, dynamic> raw;

  bool get isVideo => type == 'video';
  bool get isLegacy => !isVideo;
  bool get isUpload => file != null && (file!['url'] ?? '').toString().isNotEmpty;

  /// Server limit: a longer lesson title is a 400 "Lesson N in "<section>" title
  /// must be at most 150 characters" (backend fix #2). Kept as inline validation.
  static const maxTitle = 150;

  factory CourseLesson.fromJson(Map j) => CourseLesson(
        id: j['_id']?.toString(),
        title: '${j['title'] ?? ''}',
        type: '${j['type'] ?? 'video'}',
        file: j['file'] is Map ? Map<String, dynamic>.from(j['file'] as Map) : null,
        videoUrl: (j['videoUrl'] as String?)?.trim().isEmpty == true ? null : j['videoUrl'] as String?,
        durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
        isPreview: j['isPreview'] == true,
        raw: Map<String, dynamic>.from(j),
      );

  Map<String, dynamic> toJson() {
    if (isLegacy) return {...raw, 'title': title, 'isPreview': isPreview};
    return {
      if (id != null) '_id': id,
      'title': title,
      'type': 'video',
      if (isUpload) 'file': file else 'videoUrl': videoUrl,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      'isPreview': isPreview,
    };
  }

  /// Server rule: "Only https YouTube or Vimeo links are allowed".
  static String? validateLink(String raw) {
    final u = Uri.tryParse(raw.trim());
    if (u == null || u.scheme != 'https' || u.host.isEmpty) return 'Paste an https YouTube or Vimeo link.';
    final h = u.host.toLowerCase();
    const ok = ['youtube.com', 'www.youtube.com', 'm.youtube.com', 'youtu.be', 'vimeo.com', 'www.vimeo.com', 'player.vimeo.com'];
    if (!ok.contains(h)) return 'Only YouTube or Vimeo links are allowed.';
    return null;
  }

  String get sourceLabel {
    if (isLegacy) return 'Older ${type.toUpperCase()} lesson (still plays)';
    if (isUpload) return 'Video: ${file!['name'] ?? 'uploaded'}';
    final h = Uri.tryParse(videoUrl ?? '')?.host ?? '';
    return h.contains('vimeo') ? 'Vimeo link' : 'YouTube link';
  }
}

class CourseSection {
  CourseSection({this.id, required this.title, List<CourseLesson>? lessons}) : lessons = lessons ?? [];
  final String? id;
  String title;
  final List<CourseLesson> lessons;

  /// Server limit: a longer section title is a 400 "Section N title must be at
  /// most 120 characters" (backend fix #2). Kept as inline validation.
  static const maxTitle = 120;

  factory CourseSection.fromJson(Map j) => CourseSection(
        id: j['_id']?.toString(),
        title: '${j['title'] ?? ''}',
        lessons: (j['lessons'] as List? ?? const []).whereType<Map>().map(CourseLesson.fromJson).toList(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'title': title,
        'lessons': [for (final l in lessons) l.toJson()],
      };
}

/// GET/PUT /api/courses/seller/:storeId/:productId
class CourseContent {
  CourseContent({
    this.productName = '',
    this.productStatus = '',
    this.deliveryFormat = '',
    List<CourseSection>? sections,
    List<String>? outcomes,
    this.instructorName = '',
    this.instructorBio = '',
    this.accessDays,
    this.certificateEnabled = true,
    Map<String, dynamic>? certificate,
    this.learners = 0,
  })  : sections = sections ?? [],
        outcomes = outcomes ?? [],
        certificate = certificate ?? {};

  final String productName, productStatus, deliveryFormat;
  final List<CourseSection> sections;
  final List<String> outcomes;
  String instructorName, instructorBio;
  int? accessDays; // null = lifetime
  bool certificateEnabled;

  /// watermarkText (<=40), watermarkImageUrl, stampImageUrl,
  /// signatureImageUrl, signatureName / signatureTitle / issuerName (<=80).
  /// Image URLs must come from an Edudeen upload.
  final Map<String, dynamic> certificate;
  final int learners;

  static const maxOutcomes = 10, maxOutcome = 200, maxInstructorName = 100, maxBio = 1000;
  static const maxWatermark = 40, maxCertText = 80, maxAccessDays = 3650;
  static const certificateKeys = [
    'watermarkText', 'watermarkImageUrl', 'stampImageUrl', 'signatureImageUrl',
    'signatureName', 'signatureTitle', 'issuerName',
  ];

  factory CourseContent.fromJson(Map j) {
    final p = j['product'] is Map ? j['product'] as Map : const {};
    final ins = j['instructor'] is Map ? j['instructor'] as Map : const {};
    final cert = j['certificateConfig'] is Map ? Map<String, dynamic>.from(j['certificateConfig'] as Map) : <String, dynamic>{};
    return CourseContent(
      productName: '${p['name'] ?? ''}',
      productStatus: '${p['status'] ?? ''}',
      deliveryFormat: '${p['deliveryFormat'] ?? ''}',
      sections: (j['sections'] as List? ?? const []).whereType<Map>().map(CourseSection.fromJson).toList(),
      outcomes: (j['outcomes'] as List? ?? const []).map((e) => '$e').toList(),
      instructorName: '${ins['name'] ?? ''}',
      instructorBio: '${ins['bio'] ?? ''}',
      accessDays: (j['accessDays'] as num?)?.toInt(),
      certificateEnabled: j['certificateEnabled'] != false,
      certificate: cert,
      learners: (j['learners'] as num?)?.toInt() ?? 0,
    );
  }

  /// PUT replaces the course: everything is sent every time.
  Map<String, dynamic> toBody() => {
        'sections': [for (final s in sections) s.toJson()],
        'outcomes': outcomes,
        'instructor': {'name': instructorName, 'bio': instructorBio},
        'accessDays': accessDays,
        'certificateEnabled': certificateEnabled,
        'certificateConfig': {
          for (final k in certificateKeys)
            k: (certificate[k] is String && (certificate[k] as String).trim().isEmpty) ? null : certificate[k],
        },
      };

  /// Same rules as the API; null when OK.
  String? validate() {
    for (final s in sections) {
      if (s.title.trim().isEmpty) return 'Every section needs a title.';
      for (final l in s.lessons) {
        if (l.title.trim().isEmpty) return 'Every lesson in "${s.title}" needs a title.';
        if (l.isVideo && !l.isUpload && (l.videoUrl == null || CourseLesson.validateLink(l.videoUrl!) != null)) {
          return '"${l.title}": upload the video or paste a YouTube/Vimeo link.';
        }
      }
    }
    if (outcomes.length > maxOutcomes) return 'Add up to 10 learning outcomes.';
    if (outcomes.any((o) => o.length > maxOutcome)) return 'An outcome can be up to 200 characters.';
    if (instructorName.length > maxInstructorName) return 'Instructor name can be up to 100 characters.';
    if (instructorBio.length > maxBio) return 'Instructor bio can be up to 1000 characters.';
    if (accessDays != null && (accessDays! < 1 || accessDays! > maxAccessDays)) {
      return 'Access duration must be 1-3650 days (or lifetime).';
    }
    if ('${certificate['watermarkText'] ?? ''}'.length > maxWatermark) return 'Watermark text can be up to 40 characters.';
    for (final k in ['signatureName', 'signatureTitle', 'issuerName']) {
      if ('${certificate[k] ?? ''}'.length > maxCertText) return 'Certificate names and titles can be up to 80 characters.';
    }
    return null;
  }
}

class SellerCourseRepository {
  SellerCourseRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  /// Throws [CourseLoadException] with the server's message (e.g. 400
  /// "Invalid id" for a bad store / product id, 404 for a missing course).
  Future<CourseContent> load(String storeId, String productId) async {
    try {
      final res = await _client.get(ApiConstants.sellerCourse(storeId, productId), requiresAuth: true);
      return CourseContent.fromJson((res.data as Map)['data'] as Map);
    } on DioException catch (e) {
      throw CourseLoadException(ApiError.fromDio(e));
    }
  }

  Future<({bool ok, CourseContent? saved, String? message})> save(String storeId, String productId, CourseContent c) async {
    try {
      final res = await _client.put(ApiConstants.sellerCourse(storeId, productId), data: c.toBody(), requiresAuth: true);
      final b = res.data is Map ? res.data as Map : const {};
      final ok = b['success'] == true && b['data'] is Map;
      return (ok: ok, saved: ok ? CourseContent.fromJson(b['data'] as Map) : null, message: ApiError.msg(b['message']));
    } on DioException catch (e) {
      return (ok: false, saved: null, message: ApiError.fromDio(e) ?? 'Could not save the course.');
    }
  }

  static const videoExtensions = ['mp4', 'webm', 'mov'];
  static const maxVideoBytes = 500 * 1024 * 1024; // private-file limit

  /// Private upload with progress (POST /api/upload/private-file). Real:
  /// {success, data: {publicId, resourceType: "video", fileName, fileSize,
  /// mimeType}} -> lesson file {url: publicId, name, size, mimeType}.
  Future<Map<String, dynamic>> uploadVideo(File file, {void Function(double)? onProgress, CancelToken? cancel}) async {
    final name = file.path.split('/').last;
    if (!videoExtensions.contains(UploadRules.extensionOf(name))) {
      throw const CourseUploadException('Pick an MP4, WebM or MOV video.');
    }
    if (await file.length() > maxVideoBytes) throw const CourseUploadException('The video must be under 500 MB.');
    final dio = await DioService.getDio();
    try {
      final res = await dio.post(
        ApiConstants.uploadPrivateFile,
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path, filename: name, contentType: DioMediaType.parse(UploadRules.mimeFromExtension(name))),
        }),
        options: Options(extra: {'requiresAuth': true}, receiveTimeout: const Duration(minutes: 5)),
        cancelToken: cancel,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
      final d = (res.data as Map)['data'] as Map;
      return {'url': d['publicId'], 'name': d['fileName'] ?? name, 'size': d['fileSize'], 'mimeType': d['mimeType']};
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) throw const CourseUploadException('Upload cancelled.', cancelled: true);
      throw CourseUploadException(ApiError.fromDio(e) ?? 'Upload failed. Check your connection and retry.');
    }
  }
}

class CourseUploadException implements Exception {
  const CourseUploadException(this.message, {this.cancelled = false});
  final String message;
  final bool cancelled;
  @override
  String toString() => message;
}

/// A course that could not be loaded; [message] is the server's text if any.
class CourseLoadException implements Exception {
  const CourseLoadException(this.message);
  final String? message;
  @override
  String toString() => message ?? 'Could not load the course.';
}
