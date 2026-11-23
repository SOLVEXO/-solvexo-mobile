import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

/// Public shelves reached by deep link (R2): bundles, curated picks and
/// learning paths. All return the server's shaped data; 404 -> null.
class CollectionsRepository {
  CollectionsRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  Future<Map?> _get(String url) async {
    try {
      final r = await _client.get(url);
      final d = (r.data as Map)['data'];
      return d is Map ? d : null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// GET /api/bundles/public/:slug -> {name, storeName, currency, totalPrice,
  /// bundlePrice, savings, discountPercent, products[]}.
  Future<Map?> bundle(String slug) => _get(ApiConstants.bundleBySlug(slug));

  /// GET /api/curated-collections/:slug -> {title, subtitle, description, products[]}.
  Future<Map?> picks(String slug) => _get(ApiConstants.curatedCollection(slug));

  /// GET /api/learning-paths/:slug -> {title, subtitle, ageLabel, steps[{title, note, products[]}]}.
  Future<Map?> learningPath(String slug) => _get(ApiConstants.learningPath(slug));

  /// GET /api/learning-paths -> active paths.
  Future<List<Map>> learningPaths() async {
    final r = await _client.get(ApiConstants.learningPaths);
    return ((r.data as Map)['data'] as List? ?? []).whereType<Map>().toList();
  }
}
