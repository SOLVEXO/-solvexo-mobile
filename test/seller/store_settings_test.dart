import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/seller_store_settings_repository.dart';
import 'package:book_store_app/app/modules/seller_store_settings/controllers/seller_store_settings_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

// #15 Store settings. Fixture = the settings fields of the real
// update-store response on the test store (2026-11-18).
final _store = jsonDecode(File('test/fixtures/store_settings.json').readAsStringSync()) as Map<String, dynamic>;

class _Client extends BaseClient {
  dynamic posted;

  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    final ro = RequestOptions(path: url);
    if (url.endsWith('getShippingZones')) {
      return Response(requestOptions: ro, statusCode: 200, data: {'message': 'Shipping zones fetched successfully', 'data': []});
    }
    return Response(requestOptions: ro, statusCode: 200, data: {'success': true, 'data': _store});
  }

  @override
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true, Map<String, dynamic>? headers}) async {
    posted = data;
    return Response(requestOptions: RequestOptions(path: url), statusCode: 201,
        data: {'success': true, 'message': 'Store updated successfully', 'data': {..._store, ...data as Map}});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('parses the real settings and writes whole objects back', () {
    final s = StoreSettings.fromJson(_store);
    expect(s.productTypes, ['physical_products', 'digital_downloads']);
    expect(s.codEnabled, isTrue);
    expect((s.deliveryFeeOn, s.deliveryFee, s.freeOverAmount), (true, 150, 3000));
    expect((s.giftWrapOn, s.giftWrapFee), (true, 100));
    expect(s.deliveryDays['national']!.max, 6);
    expect(s.dispatchDays, 2);
    expect((s.shipFromCity, s.shipFromProvince), ('Lahore', 'Punjab'));
    expect(s.returnNote, 'Returns within 7 days if damaged.');
    expect(s.digitalReturnNote, 'Digital files cannot be returned.');

    final body = s.toBody('s1');
    expect(body['deliveryDays'], _store['deliveryDays']);
    expect(body['deliverySettings'], _store['deliverySettings']);
    expect(body['giftWrap'], _store['giftWrap']);
    expect(body['shipFrom'], _store['shipFrom']);
    expect(body['returnPolicy'], _store['returnPolicy']);
  });

  test('a store with nothing set (live test store) parses to defaults', () {
    final s = StoreSettings.fromJson({'baseCurrency': 'PKR', 'codEnabled': true, 'productTypes': ['physical_products'],
      'deliverySettings': null, 'giftWrap': null, 'deliveryDays': null, 'shipFrom': null, 'returnPolicy': null, 'dispatchDays': 2});
    expect(s.deliveryDays, isEmpty);
    expect(s.toBody('s1')['deliveryDays'], isNull);
    expect(s.toBody('s1')['shipFrom'], isNull);
  });

  test('validation follows the API limits', () async {
    final client = _Client();
    final c = SellerStoreSettingsController(repository: SellerStoreSettingsRepository(client: client), storeId: 's1');
    await c.load();
    expect(c.validate(), isNotNull);

    c.physical.value = false;
    c.digital.value = false;
    c.dispatchDays.text = '9';
    c.days['national']!.$1.text = '5';
    c.days['national']!.$2.text = '2';
    c.deliveryFee.text = '150.5'; // PKR is whole rupees
    c.returnWindow.text = '91';
    c.returnNote.text = 'x' * 301;
    expect(c.validate(), isNull);
    expect(c.errors.keys, containsAll(['types', 'dispatchDays', 'days_national', 'deliveryFee', 'returnWindow', 'returnNote']));
    expect(c.errors['days_national'], 'The minimum cannot be more than the maximum.');
  });

  test('save posts the whole settings body', () async {
    final client = _Client();
    final c = SellerStoreSettingsController(repository: SellerStoreSettingsRepository(client: client), storeId: 's1');
    await c.load();
    c.cod.value = false;
    c.touch();
    expect(await c.save(), isTrue);
    expect(client.posted['codEnabled'], isFalse);
    expect(client.posted['storeId'], 's1');
    expect(client.posted['returnPolicy']['digitalNote'], 'Digital files cannot be returned.');
    expect(c.dirty.value, isFalse);
  });

  test('zones list (live: empty)', () async {
    expect(await SellerStoreSettingsRepository(client: _Client()).zones(), isEmpty);
    final z = ShippingZone.fromJson({'country': 'Pakistan', 'province': 'Punjab', 'city': 'Lahore', 'shippingPrice': 200, 'estimatedDeliveryTime': '2-3 days', 'status': 'active'});
    expect(z.place, 'Lahore, Punjab, Pakistan');
  });

  test('province without a city is an error, not a silent drop (5adba44)', () async {
    final c = SellerStoreSettingsController(repository: SellerStoreSettingsRepository(client: _Client()), storeId: 's1');
    await c.load();
    c.city.text = '';
    c.province.value = 'Punjab';
    expect(c.validate(), isNull);
    expect(c.errors['city'], contains('city'));
    c.province.value = null;
    expect(c.validate(), isNotNull, reason: 'no city and no province is fine');
    c.city.text = 'x' * 61;
    expect(c.validate(), isNull);
    expect(c.errors['city'], contains('60'));
  });
}
