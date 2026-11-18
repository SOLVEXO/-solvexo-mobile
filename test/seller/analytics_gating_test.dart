import 'package:book_store_app/app/data/repositories/seller_analytics_repository.dart';
import 'package:book_store_app/app/modules/seller_analytics/controllers/seller_analytics_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// #16. Live answers for the Free Trial test store (2026-11-18): today,
// overview, revenue/orders-over-time and top-products are 200; the rest
// are 403 with this body.
const _lockBody = {
  'message': 'Advanced analytics is not included in your current platform plan — available starting with the "Pro" plan.',
  'error': 'Forbidden',
  'statusCode': 403,
};
const _gated = ['traffic-sources', 'customers', 'products/performance', 'inventory-insights', 'payment-methods', 'revenue-breakdown', 'export'];

class _Client extends BaseClient {
  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    final ro = RequestOptions(path: url);
    if (_gated.any(url.endsWith)) {
      throw DioException(
        requestOptions: ro,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: ro, statusCode: 403, data: _lockBody),
      );
    }
    final Object payload = switch (url.split('/').last) {
      'top-products' => <dynamic>[],
      'revenue-over-time' => {'granularity': 'day', 'currency': 'PKR', 'series': []},
      'orders-over-time' => {'granularity': 'day', 'series': []},
      _ => {'currency': 'PKR', 'timezone': 'Asia/Karachi', 'bookedValue': 0, 'collected': 0, 'totalOrders': 0},
    };
    return Response(requestOptions: ro, statusCode: 200, data: {'success': true, 'data': payload});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('403 becomes a lock with the server message, not an error', () async {
    final repo = SellerAnalyticsRepository(client: _Client());
    expect(() => repo.getTrafficSources('s1', '30d'), throwsA(isA<PlanLockedException>()
        .having((e) => e.message, 'message', contains('"Pro" plan'))));
  });

  test('overview keeps free sections and locks the advanced ones', () async {
    final c = SellerAnalyticsController(repository: SellerAnalyticsRepository(client: _Client()))..storeId = 's1';
    await c.loadOverview();
    expect(c.isLoadingOverview.value, isFalse);
    expect(c.locked.keys, containsAll(['traffic', 'payments', 'breakdown']));
    expect(c.locked.containsKey('overview'), isFalse);
    expect(c.overview.value.currency, 'PKR');

    await c.loadProducts();
    await c.loadCustomers();
    await c.loadInventory();
    for (final t in [AnalyticsTab.products, AnalyticsTab.customers, AnalyticsTab.inventory]) {
      expect(c.lockFor(t), contains('Advanced analytics'));
    }
    expect(c.lockFor(AnalyticsTab.overview), isNull);
  });

  test('a byte-body 403 (PDF export) still reads the message', () {
    final ro = RequestOptions(path: 'x');
    final e = DioException(
      requestOptions: ro,
      response: Response(requestOptions: ro, statusCode: 403, data: '{"message":"Advanced analytics is not included"}'.codeUnits),
    );
    expect(PlanLockedException.from(e)!.message, 'Advanced analytics is not included');
  });
}
