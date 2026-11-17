import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

/// Data for the Library tab (docs §5.9): purchased digital files come from
/// the buyer's orders, courses from `GET /api/courses/mine`. Errors are
/// thrown so the screen can show Retry instead of a fake empty state.
class LibraryRepository {
  LibraryRepository({OrderRepository? orders, BaseClient? client})
      : _orders = orders ?? OrderRepository(),
        _client = client ?? BaseClient();

  final OrderRepository _orders;
  final BaseClient _client;

  /// Reads up to [maxPages] pages of orders (newest first) and keeps the
  /// digital download items. Online courses are excluded here; they appear
  /// in the Courses tab.
  ///
  /// Order items carry no delivery format (verified 2026-11-17: item keys
  /// are type/productType/name/productId/...), so a course is recognised by
  /// its productId being in GET /api/courses/mine, or by the product's own
  /// `deliveryFormat == 'course'` (GET getProductById). A product that no
  /// longer exists ("Product not found") is kept but marked unavailable.
  Future<List<LibraryFile>> fetchFiles({int maxPages = 5}) async {
    final digital = <LibraryFile>[];
    for (var page = 1; page <= maxPages; page++) {
      final List<OrderModel> batch =
          await _orders.getMyOrders(page: page, limit: 50);
      for (final order in batch) {
        if (order.isCancelled) continue;
        for (final item in order.allItems) {
          if (item.type == 'digital') {
            digital.add(LibraryFile(order: order, item: item));
          }
        }
      }
      if (batch.length < 50) break;
    }

    final courseIds = <String>{};
    try {
      courseIds.addAll((await fetchCourses()).map((c) => c.id));
    } catch (_) {}
    final ids = digital.map((f) => f.item.productId).toSet()..removeAll(courseIds);
    final formats = <String, String?>{};
    await Future.wait(ids.map((id) async => formats[id] = await _deliveryFormat(id)));

    final files = <LibraryFile>[];
    for (final f in digital) {
      final id = f.item.productId;
      if (courseIds.contains(id) || formats[id] == 'course') continue;
      files.add(formats[id] == _missing
          ? LibraryFile(order: f.order, item: f.item, available: false)
          : f);
    }
    files.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return files;
  }

  static const _missing = '__missing__';
  static final Map<String, String?> _formatCache = {};

  /// 'course' | 'download' | null (unknown) | [_missing] (product gone).
  Future<String?> _deliveryFormat(String productId) async {
    if (_formatCache.containsKey(productId)) return _formatCache[productId];
    try {
      final res = await _client.get(ApiConstants.getProductById(productId));
      final body = res.data;
      final data = body is Map ? body['data'] : null;
      final p = data is Map ? (data['product'] is Map ? data['product'] : data) : null;
      final String? format;
      if (body is Map && body['success'] != true && p == null) {
        format = _missing;
      } else if (p is Map && p['_id'] == null && p['deliveryFormat'] == null) {
        format = _missing;
      } else {
        format = p is Map ? p['deliveryFormat']?.toString() : null;
      }
      return _formatCache[productId] = format;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return _formatCache[productId] = _missing;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<LibraryCourse>> fetchCourses() async {
    final res = await _client.get(ApiConstants.myCourses, requiresAuth: true);
    final body = res.data;
    dynamic data = body is Map ? body['data'] : null;
    if (data is Map) data = data['courses'] ?? data['items'] ?? data['data'];
    if (data is! List) return const [];
    return data
        .map(LibraryCourse.fromJson)
        .whereType<LibraryCourse>()
        .where((c) => c.isPublished)
        .toList();
  }
}
