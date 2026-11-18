import 'package:book_store_app/app/modules/library/models/library_models.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';

/// Data for the Library tab (docs §5.9): files from GET /api/orders/my-library,
/// courses from GET /api/courses/mine. Errors are thrown so the screen can
/// show Retry instead of a fake empty state.
class LibraryRepository {
  LibraryRepository({BaseClient? client}) : _client = client ?? BaseClient();

  final BaseClient _client;

  /// One call: the server returns every purchased digital item with its
  /// `deliveryFormat` and availability. Online courses are left out here
  /// (they are in the Courses tab). Newest first.
  Future<List<LibraryFile>> fetchFiles() async {
    final res = await _client.get(ApiConstants.myLibrary, requiresAuth: true);
    final data = (res.data as Map)['data'];
    final items = data is Map && data['items'] is List ? data['items'] as List : const [];
    final files = items.whereType<Map>().map(LibraryFile.fromJson).where((f) => !f.isCourse).toList()
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
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
