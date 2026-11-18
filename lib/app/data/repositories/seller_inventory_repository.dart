import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/api_error.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';

// Inventory (docs 6.4; checklist #13). Shapes from real calls on the test
// store (2026-11-18).

class InventoryStats {
  const InventoryStats({this.total = 0, this.inStock = 0, this.lowStock = 0, this.outOfStock = 0, this.unlimited = 0});
  final int total, inStock, lowStock, outOfStock, unlimited;

  /// data.stats: {totalProducts, inStock, lowStock, outOfStock, unlimited, statusCounts}
  factory InventoryStats.fromJson(Map j) {
    int n(String k) => (j[k] as num?)?.toInt() ?? 0;
    return InventoryStats(
      total: n('totalProducts'),
      inStock: n('inStock'),
      lowStock: n('lowStock'),
      outOfStock: n('outOfStock'),
      unlimited: n('unlimited'),
    );
  }
}

/// GET /api/inventory/stock-history/:storeId/:productId ->
/// {success, data: {items: [{id, old, new, source, createdAt}]}}
class StockHistoryEntry {
  const StockHistoryEntry({required this.id, required this.from, required this.to, required this.source, this.at});
  final String id;
  final int? from;
  final int? to;
  final String source; // manual | bulk | order ...
  final DateTime? at;

  factory StockHistoryEntry.fromJson(Map j) => StockHistoryEntry(
        id: '${j['id'] ?? j['_id'] ?? ''}',
        from: (j['old'] as num?)?.toInt(),
        to: (j['new'] as num?)?.toInt(),
        source: '${j['source'] ?? ''}',
        at: DateTime.tryParse('${j['createdAt'] ?? ''}'),
      );
}

typedef BulkStockResult = ({int updated, List<String> skipped, String? message});

class SellerInventoryRepository {
  SellerInventoryRepository({BaseClient? client}) : _client = client ?? BaseClient();
  final BaseClient _client;

  /// Physical products only (`type=physical`, verified). Throws on failure.
  Future<({List<Map<String, dynamic>> rows, InventoryStats stats, bool hasMore})> fetchPhysical({
    required String storeId,
    int page = 1,
    int limit = 20,
    String? query,
  }) async {
    final res = await _client.get(
      ApiConstants.getStoreInventory(storeId),
      queryParameters: {
        'page': page,
        'limit': limit,
        'type': 'physical',
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      },
      requiresAuth: true,
    );
    final data = (res.data as Map)['data'] as Map;
    final pagination = data['pagination'] is Map ? data['pagination'] as Map : const {};
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;
    return (
      rows: (data['products'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList(),
      stats: InventoryStats.fromJson(data['stats'] is Map ? data['stats'] as Map : const {}),
      hasMore: page < totalPages,
    );
  }

  /// Exact stock per variant: PATCH /api/products/stock/bulk
  /// {storeId, updates: [{variantId, stock}]}.
  Future<BulkStockResult> setStocks(String storeId, Map<String, int> stockByVariant) => _bulk({
        'storeId': storeId,
        'updates': [
          for (final e in stockByVariant.entries) {'variantId': e.key, 'stock': e.value},
        ],
      });

  /// Bulk by product: {storeId, mode: set|add|subtract, ids, value 0-100000}.
  /// Real: updated [{id, name, from, to}], skipped [{id, name, code, reason}].
  Future<BulkStockResult> bulkStock(String storeId, {required String mode, required List<String> productIds, required int value}) =>
      _bulk({'storeId': storeId, 'mode': mode, 'ids': productIds, 'value': value});

  Future<BulkStockResult> _bulk(Map<String, dynamic> body) async {
    try {
      final res = await _client.patch(ApiConstants.productsStockBulk, data: body, requiresAuth: true);
      final b = res.data is Map ? res.data as Map : const {};
      final data = b['data'] is Map ? b['data'] as Map : const {};
      final updated = data['updated'];
      final skipped = data['skipped'] is List ? data['skipped'] as List : const [];
      return (
        updated: updated is List ? updated.length : (updated is num ? updated.toInt() : 0),
        skipped: [
          for (final s in skipped)
            if (s is Map) '${s['name'] ?? s['id'] ?? s['variantId']}: ${s['reason'] ?? 'skipped'}' else '$s',
        ],
        message: ApiError.msg(b['message']),
      );
    } on DioException catch (e) {
      return (updated: 0, skipped: const <String>[], message: ApiError.fromDio(e) ?? 'Could not change the stock.');
    }
  }

  /// PATCH /api/inventory/low-stock-threshold/:storeId/:productId
  /// {threshold: 0-1000 | null (default)} ->
  /// {success, data: {productId, lowStockThreshold, hasCustomThreshold}}.
  Future<({bool ok, int? threshold, bool custom, String? message})> setLowStockThreshold(
      String storeId, String productId, int? threshold) async {
    try {
      final res = await _client.patch(
        ApiConstants.lowStockThreshold(storeId, productId),
        data: {'threshold': threshold},
        requiresAuth: true,
      );
      final b = res.data is Map ? res.data as Map : const {};
      final d = b['data'] is Map ? b['data'] as Map : const {};
      return (
        ok: b['success'] == true,
        threshold: (d['lowStockThreshold'] as num?)?.toInt(),
        custom: d['hasCustomThreshold'] == true,
        message: ApiError.msg(b['message']),
      );
    } on DioException catch (e) {
      return (ok: false, threshold: null, custom: false, message: ApiError.fromDio(e) ?? 'Could not save the limit.');
    }
  }

  /// Newest first; the app shows the last 20. Throws on failure.
  Future<List<StockHistoryEntry>> stockHistory(String storeId, String productId) async {
    final res = await _client.get(ApiConstants.stockHistory(storeId, productId), requiresAuth: true);
    final data = (res.data as Map)['data'];
    final items = data is Map && data['items'] is List ? data['items'] as List : const [];
    return items.whereType<Map>().map(StockHistoryEntry.fromJson).take(20).toList();
  }
}
