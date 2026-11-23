import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/buyer_extras_repository.dart';
import 'package:book_store_app/app/data/repositories/checkout_repository.dart';
import 'package:book_store_app/app/data/repositories/manual_transfer_repository.dart';
import 'package:book_store_app/app/modules/checkout/controllers/checkout_controller.dart';
import 'package:book_store_app/app/modules/product_details/widgets/buyer_extras_widgets.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Live (test buyer, 2026-11-20):
// GET /api/cart/buy-now?productId=6ace2a1a..&variantId=6ace2a1a..bc&quantity=1 -> 200 "Buy Now line fetched successfully"
//   data:[{storeId, items:[{name:"Noorani Qaida Colour-Coded Set", type:"physical", currency:"PKR", unitPrice:1140,
//   quantity:1, itemTotal:1140}], totalPrice:1140, currency:"PKR", totalAfterDiscount:1140, store:{name:"Jami Store"}}]
// GET /api/checkout/delivery-info?...&currency=PKR -> {kind:"physical", currency:"PKR", fee:null, estimate:null,
//   freeShipping:false, cod:false, dispatchDays:null, routeDays:null}
// GET /api/search/trending?limit=8 -> {success:true, data:[]}
// POST /api/checkout/create-checkout {buyNow:{..}, addressId} -> 201 allowedPaymentMethods:["stripe"]; then
//   DELETE /api/checkout/delete-checkout/:id -> 200; my-carts still [] (cart untouched)
// Seller session: POST create-checkout -> 403 "Access Denied: Insufficient role"
// GET /api/orders/download-zip-link/:orderId/:productId -> 400 "No digital files found for this product"
const _buyNow = {
  'storeId': 's',
  'items': [
    {'productId': 'p', 'name': 'Noorani Qaida Colour-Coded Set', 'type': 'physical', 'currency': 'PKR', 'unitPrice': 1140, 'quantity': 1, 'itemTotal': 1140}
  ],
  'totalPrice': 1140,
  'currency': 'PKR',
  'totalAfterDiscount': 1140,
  'store': {'name': 'Jami Store'},
};

class _Client extends BaseClient {
  _Client(this.reply);
  final Object reply;
  String? url;
  Map<String, dynamic>? query, headers;
  Response _r(String u) => Response(requestOptions: RequestOptions(path: u), statusCode: 200, data: reply);
  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    this.url = url;
    query = queryParameters;
    return _r(url);
  }

  @override
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true, Map<String, dynamic>? headers}) async {
    this.url = url;
    this.headers = headers;
    return _r(url);
  }
}

void main() {
  test('buy-now: server totals, cart untouched (GET only)', () async {
    final c = _Client({'data': [_buyNow]});
    final l = await BuyerExtrasRepository(client: c).buyNow(productId: 'p', variantId: 'v', quantity: 2);
    expect(c.url, endsWith('/cart/buy-now'));
    expect(c.query, {'productId': 'p', 'variantId': 'v', 'quantity': '2'});
    expect(l.total, 1140);
    expect(l.currency, 'PKR');
    expect(l.isPhysical, isTrue);
    expect(l.storeName, 'Jami Store');
  });

  test('delivery info lines use only server values', () {
    final live = DeliveryInfo({'kind': 'physical', 'currency': 'PKR', 'fee': null, 'freeShipping': false, 'cod': false, 'dispatchDays': null, 'routeDays': null});
    expect(DeliveryInfoRow.lines(live), ['Delivery fee is shown at checkout']);
    final full = DeliveryInfo({'kind': 'physical', 'currency': 'PKR', 'fee': 250, 'cod': true, 'routeDays': {'min': 2, 'max': 4}});
    expect(DeliveryInfoRow.lines(full), ['Delivery: Rs 250', 'Arrives in 2-4 days', 'Cash on delivery available']);
    expect(DeliveryInfoRow.lines(DeliveryInfo({'kind': 'digital'})), ['Instant digital delivery']);
  });

  test('trending + zip link', () async {
    final t = await BuyerExtrasRepository(client: _Client({'data': [{'query': 'urdu', 'searches': 4}]})).trending();
    expect(t, ['urdu']);
    final c = _Client({'data': {'token': 'abc', 'endpoint': '/api/orders/download-zip-file'}});
    final url = await BuyerExtrasRepository(client: c).zipLink('o1', 'p1');
    expect(c.url, endsWith('/orders/download-zip-link/o1/p1'));
    expect(url, endsWith('/api/orders/download-zip-file?token=abc'));
  });

  test('free + COD send an Idempotency-Key and reach success', () async {
    final ok = {'success': true, 'data': {'orders': [{'orderId': 'o1'}]}};
    final c = _Client(ok);
    final free = await CheckoutRepository(client: c).placeFreeOrder('ck1');
    expect(c.url, endsWith('/payment/free-checkout'));
    expect(c.headers, {'Idempotency-Key': 'free:ck1'});
    expect(free.success, isTrue);
    expect(free.orderIds, ['o1']);
    final cod = await CheckoutRepository(client: c).placeCodOrder('ck1');
    expect(c.headers, {'Idempotency-Key': 'cod:ck1'});
    expect(cod.success, isTrue);
  });

  test('bank proof key is stable per checkout + file', () {
    final f = File('${Directory.systemTemp.path}/proof_test.jpg')..writeAsBytesSync([1, 2, 3]);
    expect(ManualTransferRepository.manualProofKey('ck1', f), 'manual-proof:ck1:proof_test.jpg:3');
    expect(ManualTransferRepository.manualProofKey('ck1', f), ManualTransferRepository.manualProofKey('ck1', f));
    f.deleteSync();
  });

  test('card only with a Stripe key AND a USD checkout', () {
    expect(CheckoutController.onlineAllowed(['stripe'], 'USD', true), isTrue);
    expect(CheckoutController.onlineAllowed(['stripe'], 'USD', false), isFalse);
    expect(CheckoutController.onlineAllowed(['stripe'], 'PKR', true), isFalse);
    expect(CheckoutController.onlineAllowed(['free'], 'USD', true), isFalse);
  });

  test('buy-now 403 (seller session, backend fix #8) is a BuyerOnlyException, not a raw error', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final c = _Client403();
    await expectLater(BuyerExtrasRepository(client: c).buyNow(productId: 'p', variantId: 'v'), throwsA(isA<BuyerOnlyException>()));
  });
}

class _Client403 extends BaseClient {
  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    final ro = RequestOptions(path: url);
    throw DioException(requestOptions: ro, type: DioExceptionType.badResponse,
        response: Response(requestOptions: ro, statusCode: 403, data: {'message': 'Access Denied: Insufficient role', 'statusCode': 403}));
  }
}
