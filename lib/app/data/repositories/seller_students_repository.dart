import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

// Students roster (docs 6.9; checklist #14b).
//
// Verified live (2026-11-18, test store with no students):
//   GET /api/courses/seller/:storeId/roster?status&productId&q&sort&page&limit
//   -> {success, data: {total, page, limit (max 50), totalPages, rows: [],
//       products: [], stats: {totalStudents, avgCompletionPct, active7d},
//       statusCounts: {all, notStarted, inProgress, completed, inactive14}}}
//   status: all | not_started | in_progress | completed | inactive14
//   sort: activity | progress | name | enrolled
//   GET .../roster/export -> CSV: Student, Email, Product, Type, Enrolled,
//       Free, Progress %, Lessons done, Downloads, Last activity, Status, Access
//
// NOT verified: a roster row and a `products` entry (the list is empty on
// the test store). [StudentRow] reads them defensively, following the CSV
// columns; re-check against a real row before release.

enum StudentStatus {
  all('all', 'All', 'all'),
  notStarted('not_started', 'Not started', 'notStarted'),
  inProgress('in_progress', 'In progress', 'inProgress'),
  completed('completed', 'Completed', 'completed'),
  inactive('inactive14', 'Inactive 14 d', 'inactive14');

  const StudentStatus(this.api, this.label, this.countKey);
  final String api, label, countKey;

  static StudentStatus? fromApi(String? s) {
    for (final v in values) {
      if (v.api == s || v.countKey == s) return v;
    }
    return null;
  }
}

enum StudentSort {
  activity('activity', 'Last activity'),
  progress('progress', 'Progress'),
  name('name', 'Name'),
  enrolled('enrolled', 'Enrolled');

  const StudentSort(this.api, this.label);
  final String api, label;
}

class StudentRow {
  const StudentRow({
    required this.buyerId,
    required this.name,
    this.maskedEmail,
    this.productId,
    this.productName,
    this.productType,
    this.enrolledAt,
    this.isFree = false,
    this.progressPct,
    this.lessonsDone,
    this.lessonsTotal,
    this.downloads,
    this.lastActivityAt,
    this.status,
    this.accessLabel,
  });

  final String buyerId, name;
  final String? maskedEmail, productId, productName, productType, accessLabel;
  final DateTime? enrolledAt, lastActivityAt;
  final bool isFree;
  final int? progressPct, lessonsDone, lessonsTotal, downloads;
  final StudentStatus? status;

  factory StudentRow.fromJson(Map j) {
    T? pick<T>(List<String> keys) {
      for (final k in keys) {
        final v = j[k];
        if (v is T) return v;
      }
      return null;
    }

    final buyer = pick<Map>(['buyer', 'student', 'user']) ?? const {};
    final product = pick<Map>(['product']) ?? const {};
    String? str(dynamic v) => v == null || '$v'.isEmpty ? null : '$v';
    int? num_(dynamic v) => v is num ? v.round() : int.tryParse('${v ?? ''}');
    DateTime? date(dynamic v) => v == null ? null : DateTime.tryParse('$v');
    final access = j['access'] ?? j['accessEndsAt'] ?? j['accessUntil'];

    return StudentRow(
      buyerId: str(j['buyerId'] ?? j['userId'] ?? j['studentId'] ?? buyer['_id'] ?? buyer['id']) ?? '',
      name: str(j['name'] ?? j['studentName'] ?? j['buyerName'] ?? buyer['name']) ?? 'Student',
      maskedEmail: str(j['maskedEmail'] ?? j['email'] ?? buyer['maskedEmail'] ?? buyer['email']),
      productId: str(j['productId'] ?? product['_id']),
      productName: str(j['productName'] ?? product['name']),
      productType: str(j['productType'] ?? j['type'] ?? j['deliveryFormat']),
      enrolledAt: date(j['enrolledAt'] ?? j['purchasedAt'] ?? j['createdAt']),
      isFree: j['isFree'] == true || j['free'] == true || j['isFreeClaim'] == true,
      progressPct: num_(j['progressPct'] ?? j['progress'] ?? j['percent']),
      lessonsDone: num_(j['lessonsDone'] ?? j['completedLessons']),
      lessonsTotal: num_(j['lessonsTotal'] ?? j['totalLessons']),
      downloads: num_(j['downloads'] ?? j['downloadCount']),
      lastActivityAt: date(j['lastActivityAt'] ?? j['lastActivity'] ?? j['lastSeenAt']),
      status: StudentStatus.fromApi(str(j['status'])),
      accessLabel: access is String && DateTime.tryParse(access) == null ? access : null,
    );
  }

  /// The API sends a masked email; mask again in case a full one arrives.
  static String mask(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return email;
    final local = email.substring(0, at);
    if (local.contains('*')) return email;
    return '${local[0]}${'*' * (local.length - 1).clamp(1, 6)}${email.substring(at)}';
  }
}

class RosterPage {
  const RosterPage({
    this.rows = const [],
    this.products = const [],
    this.total = 0,
    this.page = 1,
    this.totalPages = 1,
    this.totalStudents = 0,
    this.avgCompletionPct,
    this.active7d = 0,
    this.counts = const {},
  });

  final List<StudentRow> rows;
  final List<({String id, String name})> products;
  final int total, page, totalPages, totalStudents, active7d;
  final num? avgCompletionPct;
  final Map<StudentStatus, int> counts;

  factory RosterPage.fromJson(Map d) {
    final stats = d['stats'] is Map ? d['stats'] as Map : const {};
    final sc = d['statusCounts'] is Map ? d['statusCounts'] as Map : const {};
    int n(dynamic v) => v is num ? v.toInt() : 0;
    return RosterPage(
      rows: (d['rows'] as List? ?? const []).whereType<Map>().map(StudentRow.fromJson).toList(),
      products: [
        for (final p in (d['products'] as List? ?? const []).whereType<Map>())
          if ((p['_id'] ?? p['id'] ?? p['productId']) != null)
            (id: '${p['_id'] ?? p['id'] ?? p['productId']}', name: '${p['name'] ?? p['title'] ?? 'Product'}'),
      ],
      total: n(d['total']),
      page: n(d['page']) == 0 ? 1 : n(d['page']),
      totalPages: n(d['totalPages']) == 0 ? 1 : n(d['totalPages']),
      totalStudents: n(stats['totalStudents']),
      avgCompletionPct: stats['avgCompletionPct'] as num?,
      active7d: n(stats['active7d']),
      counts: {for (final s in StudentStatus.values) s: n(sc[s.countKey])},
    );
  }
}

class SellerStudentsRepository {
  SellerStudentsRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  Map<String, dynamic> _query({StudentStatus status = StudentStatus.all, String? productId, String? q, StudentSort sort = StudentSort.activity}) => {
        if (status != StudentStatus.all) 'status': status.api,
        if (productId != null && productId.isNotEmpty) 'productId': productId,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        'sort': sort.api,
      };

  /// Throws on failure.
  Future<RosterPage> roster(String storeId,
      {StudentStatus status = StudentStatus.all, String? productId, String? q, StudentSort sort = StudentSort.activity, int page = 1}) async {
    final res = await _client.get(
      ApiConstants.sellerStudentsRoster(storeId),
      queryParameters: {..._query(status: status, productId: productId, q: q, sort: sort), 'page': page, 'limit': 25},
      requiresAuth: true,
    );
    return RosterPage.fromJson((res.data as Map)['data'] as Map);
  }

  /// CSV text (masked emails), same filters. Throws on failure.
  Future<String> exportCsv(String storeId, {StudentStatus status = StudentStatus.all, String? productId, String? q}) async {
    final res = await _client.get(
      ApiConstants.sellerStudentsExport(storeId),
      queryParameters: _query(status: status, productId: productId, q: q),
      requiresAuth: true,
      responseType: ResponseType.plain,
    );
    return '${res.data}';
  }

  /// POST /api/messaging/seller/start {storeId, buyerId}. Verified only
  /// the validation (no conversation was created): `{}` -> 400 ["storeId
  /// must be a mongodb id", "buyerId must be a mongodb id"]. Returns the
  /// conversation id.
  Future<({String? conversationId, String? message})> startConversation(String storeId, String buyerId) async {
    try {
      final res = await _client.post(ApiConstants.sellerStartConversation, data: {'storeId': storeId, 'buyerId': buyerId}, requiresAuth: true);
      final b = res.data is Map ? res.data as Map : const {};
      final d = b['data'] is Map ? b['data'] as Map : b;
      final conv = d['conversation'] is Map ? d['conversation'] as Map : d;
      final id = conv['_id'] ?? conv['id'] ?? d['conversationId'];
      return (conversationId: id?.toString(), message: ApiError.msg(b['message']));
    } on DioException catch (e) {
      return (conversationId: null, message: ApiError.fromDio(e) ?? 'Could not open a chat.');
    }
  }
}
