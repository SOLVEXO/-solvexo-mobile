import 'package:book_store_app/app/data/repositories/library_repository.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Order shape from the real GET /api/orders/my-orders (2026-11-17): items
/// carry type/productType but no delivery format.
Map<String, dynamic> _order(String id, String productId, String name) => {
      'orderId': id,
      'orderNumber': 'ORD-$id',
      'orderStatus': 'pending',
      'paymentStatus': 'paid',
      'paymentType': 'free',
      'isPaid': true,
      'isFreeClaim': true,
      'totalAmount': 0,
      'currency': 'PKR',
      'createdAt': '2026-11-05T05:15:26.555Z',
      'paidAt': '2026-11-05T05:15:26.555Z',
      'stores': [
        {
          'storeId': 's1',
          'storeName': 'Store',
          'status': 'pending',
          'fulfillmentType': 'digital',
          'items': [
            {
              'itemId': 'i-$id',
              'productId': productId,
              'name': name,
              'type': 'digital',
              'productType': 'digital',
              'quantity': 1,
              'price': 0,
              'totalPrice': 0,
            }
          ],
        }
      ],
    };

class _Orders extends OrderRepository {
  @override
  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 20}) async => [
        OrderModel.fromJson(_order('o1', 'pCourseMine', 'Basic Computer Skills Course')),
        OrderModel.fromJson(_order('o2', 'pCourseFormat', 'Another course')),
        OrderModel.fromJson(_order('o3', 'pGone', 'Test2 - Edu Online Course')),
        OrderModel.fromJson(_order('o4', 'pFile', 'Grade 3 Worksheets')),
      ];
}

class _Client extends BaseClient {
  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool requiresAuth = false,
    ResponseType? responseType,
  }) async {
    Object? body;
    if (url.endsWith('/courses/mine')) {
      body = {
        'success': true,
        'data': [
          {'productId': 'pCourseMine', 'name': 'Basic Computer Skills Course', 'percent': 100},
        ],
      };
    } else if (url.endsWith('/pCourseFormat')) {
      body = {'success': true, 'data': {'_id': 'pCourseFormat', 'deliveryFormat': 'course'}};
    } else if (url.endsWith('/pGone')) {
      // Real body for a removed product.
      body = {'message': 'Product not found', 'success': false, 'data': null};
    } else if (url.endsWith('/pFile')) {
      body = {'success': true, 'data': {'_id': 'pFile', 'deliveryFormat': 'download'}};
    }
    return Response(requestOptions: RequestOptions(path: url), statusCode: 200, data: body);
  }
}

void main() {
  test('Files excludes courses and marks removed products unavailable', () async {
    final files = await LibraryRepository(orders: _Orders(), client: _Client()).fetchFiles();
    final byName = {for (final f in files) f.item.name: f};
    expect(byName.keys, isNot(contains('Basic Computer Skills Course')),
        reason: 'in /courses/mine');
    expect(byName.keys, isNot(contains('Another course')), reason: "deliveryFormat 'course'");
    expect(byName['Test2 - Edu Online Course']!.available, isFalse);
    expect(byName['Test2 - Edu Online Course']!.canDownload, isFalse);
    expect(byName['Grade 3 Worksheets']!.canDownload, isTrue);
  });
}
