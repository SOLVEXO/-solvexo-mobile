import 'package:book_store_app/app/data/repositories/seller_inventory_repository.dart';
import 'package:book_store_app/app/modules/seller_inventory/controllers/seller_inventory_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// #13 Inventory. Every reply below is a real response on the test store's
// physical draft (2026-11-18).
const _row = {
  'productId': '6afc50451f2e13faea3e6522',
  'name': 'TEST DRAFT P2 physical check - do not publish',
  'type': 'physical',
  'stock': 11,
  'stockStatus': 'active',
  'status': 'draft',
  'lowStockThreshold': 10,
  'hasCustomThreshold': false,
  'price': 550,
  'variantCount': 1,
  'defaultVariantId': '6afc50451f2e13faea3e6523',
};

class _Client extends BaseClient {
  final patches = <String, dynamic>{};

  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    final ro = RequestOptions(path: url);
    if (url.contains('stock-history')) {
      return Response(requestOptions: ro, statusCode: 200, data: {
        'success': true,
        'data': {
          'items': [
            {'id': '6afd39011f2e13faea3e6536', 'old': 12, 'new': 11, 'source': 'bulk', 'createdAt': '2026-11-18T05:34:57.568Z'},
            {'id': '6afc506e1f2e13faea3e6524', 'old': 7, 'new': 9, 'source': 'manual', 'createdAt': '2026-11-17T13:02:38.850Z'},
          ],
        },
      });
    }
    expect(queryParameters?['type'], 'physical');
    return Response(requestOptions: ro, statusCode: 200, data: {
      'success': true,
      'data': {
        'stats': {'totalProducts': 1, 'inStock': 1, 'lowStock': 0, 'outOfStock': 0, 'unlimited': 0, 'statusCounts': {'draft': 1}},
        'pagination': {'page': 1, 'limit': 20, 'totalPages': 1, 'totalProducts': 1},
        'products': [_row],
      },
    });
  }

  @override
  Future<Response> patch(String url, {dynamic data, Map<String, dynamic>? headers, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) async {
    patches[url] = data;
    final ro = RequestOptions(path: url);
    if (url.contains('low-stock-threshold')) {
      if (data['threshold'] is int && data['threshold'] > 1000) {
        throw DioException(requestOptions: ro, response: Response(requestOptions: ro, statusCode: 400, data: {
          'message': 'threshold must be a whole number from 0 to 1000 (or null for the default)',
          'error': 'Bad Request',
          'statusCode': 400,
        }));
      }
      final custom = data['threshold'] != null;
      return Response(requestOptions: ro, statusCode: 200, data: {
        'success': true,
        'data': {'productId': '6afc50451f2e13faea3e6522', 'lowStockThreshold': custom ? data['threshold'] : 10, 'hasCustomThreshold': custom},
      });
    }
    if (data['mode'] != null) {
      return Response(requestOptions: ro, statusCode: 200, data: {
        'success': true,
        'data': {
          'updated': [
            {'id': '6afc50451f2e13faea3e6522', 'name': 'TEST DRAFT P2 physical check - do not publish', 'from': 11, 'to': 12},
          ],
          'skipped': [
            {'id': '6afc4ff81f2e13faea3e651c', 'name': 'TEST DRAFT P2 products check - do not publish', 'code': 'digital', 'reason': 'Digital product - no stock to change.'},
          ],
        },
      });
    }
    return Response(requestOptions: ro, statusCode: 200, data: {'success': true, 'data': {'updated': 1, 'skipped': []}});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('history, threshold and bulk shapes', () async {
    final c = _Client();
    final repo = SellerInventoryRepository(client: c);
    final h = await repo.stockHistory('s1', 'p1');
    expect(h.first.from, 12);
    expect(h.first.to, 11);
    expect(h.first.source, 'bulk');

    final t = await repo.setLowStockThreshold('s1', 'p1', 5);
    expect((t.ok, t.threshold, t.custom), (true, 5, true));
    final d = await repo.setLowStockThreshold('s1', 'p1', null);
    expect((d.threshold, d.custom), (10, false));
    expect(c.patches.values.last, {'threshold': null});
    final bad = await repo.setLowStockThreshold('s1', 'p1', 1001);
    expect(bad.ok, isFalse);
    expect(bad.message, contains('0 to 1000'));

    final b = await repo.bulkStock('s1', mode: 'add', productIds: ['a', 'b'], value: 1);
    expect(b.updated, 1);
    expect(b.skipped.single, contains('Digital product - no stock to change.'));
    expect(c.patches.values.last, {'storeId': 's1', 'mode': 'add', 'ids': ['a', 'b'], 'value': 1});
  });

  test('validation matches the server', () {
    expect(SellerInventoryController.validateThreshold('1001'), isNotNull);
    expect(SellerInventoryController.validateThreshold('-1'), isNotNull);
    expect(SellerInventoryController.validateThreshold('0'), isNull);
    expect(SellerInventoryController.validateBulkValue('100001'), isNotNull);
    expect(SellerInventoryController.validateBulkValue('100000'), isNull);
  });

  test('-/+ keeps unsaved changes and saves them in one updates call', () async {
    final client = _Client();
    final ctrl = SellerInventoryController(repository: SellerInventoryRepository(client: client), storeId: 's1');
    await ctrl.load();
    final p = ctrl.products.single;
    expect(ctrl.stats.value.inStock, 1);
    ctrl.bump(p, 1);
    ctrl.bump(p, 1);
    expect(ctrl.shownStock(p), 13);
    expect(ctrl.dirty, isTrue);
    ctrl.bump(p, -2);
    expect(ctrl.dirty, isFalse, reason: 'back to the saved value');
    ctrl.setPending(p, 0);
    expect(ctrl.pendingZero.single.id, p.id);
    await ctrl.save();
    expect(client.patches.values.last, {
      'storeId': 's1',
      'updates': [
        {'variantId': '6afc50451f2e13faea3e6523', 'stock': 0},
      ],
    });
    expect(ctrl.dirty, isFalse);
  });
}
