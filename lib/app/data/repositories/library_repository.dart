import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';

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
  Future<List<LibraryFile>> fetchFiles({int maxPages = 5}) async {
    final files = <LibraryFile>[];
    for (var page = 1; page <= maxPages; page++) {
      final List<OrderModel> batch =
          await _orders.getMyOrders(page: page, limit: 50);
      for (final order in batch) {
        if (order.isCancelled) continue;
        for (final item in order.allItems) {
          if (item.type == 'digital') {
            files.add(LibraryFile(order: order, item: item));
          }
        }
      }
      if (batch.length < 50) break;
    }
    files.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return files;
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
