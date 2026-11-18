import 'package:book_store_app/app/data/models/marketing/campaign_model.dart';
import 'package:book_store_app/app/data/repositories/campaigns_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// #12 Offers. Shapes are from real calls on the test store (2026-11-18).
class _Client extends BaseClient {
  final bodies = <dynamic>[];
  Object? getReply;

  @override
  Future<Response> patch(String url, {dynamic data, Map<String, dynamic>? headers, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) async {
    bodies.add(data);
    final ro = RequestOptions(path: url);
    if (data['action'] == 'campaign_add') {
      // Real 400 for a campaign id that is not active/upcoming.
      throw DioException(
        requestOptions: ro,
        response: Response(requestOptions: ro, statusCode: 400, data: {
          'message': 'That campaign is not available (it must be active or upcoming)',
          'error': 'Bad Request',
          'statusCode': 400,
        }),
      );
    }
    return Response(requestOptions: ro, statusCode: 200, data: {
      'success': true,
      'data': {
        'updated': ['6afc4ff81f2e13faea3e651c'],
        'skipped': [],
      },
    });
  }

  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    final ro = RequestOptions(path: url);
    if (getReply is DioException) throw getReply as DioException;
    return Response(requestOptions: ro, statusCode: 200, data: getReply);
  }
}

void main() {
  test('inventory row offer fields (after premium_on percent 10 / premium_off)', () {
    final on = SellerProduct.fromApiJson({
      'productId': 'd1', 'name': 'x', 'status': 'draft',
      'campaignIds': [], 'premiumDiscountPercent': 10, 'premiumOptOut': false,
    });
    expect(on.inPremium, isTrue);
    expect(on.premiumPercent, 10);
    expect(on.inPlatformSale, isFalse);
    final off = SellerProduct.fromApiJson({
      'productId': 'd1', 'name': 'x', 'status': 'draft',
      'campaignIds': ['c1'], 'premiumDiscountPercent': null, 'premiumOptOut': true,
    });
    expect(off.inPremium, isFalse);
    expect(off.premiumOptOut, isTrue);
    expect(off.inPlatformSale, isTrue);
  });

  test('premium percent validation matches the API (1-50)', () {
    expect(SellerProductsController.validatePremium('0'), isNotNull);
    expect(SellerProductsController.validatePremium('51'), isNotNull);
    expect(SellerProductsController.validatePremium('9.5'), isNotNull);
    expect(SellerProductsController.validatePremium('10'), isNull);
  });

  test('bulk-offers body and server errors', () async {
    final c = _Client();
    final repo = SellerProductRepository(client: c);
    final on = await repo.setOffers(storeId: 's1', productIds: ['p1'], action: 'premium_on', percent: 10);
    expect(on.updated, 1);
    expect(c.bodies.last, {'storeId': 's1', 'productIds': ['p1'], 'action': 'premium_on', 'percent': 10});
    final add = await repo.setOffers(storeId: 's1', productIds: ['p1'], action: 'campaign_add', campaignId: 'c1');
    expect(add.updated, 0);
    expect(add.message, contains('must be active or upcoming'));
  });

  test('campaign list: empty vs failed', () async {
    final c = _Client()..getReply = {'success': true, 'data': []};
    final ok = await CampaignsRepository(client: c).fetchCampaigns(storeId: 's1');
    expect(ok.failed, isFalse);
    expect(ok.items, isEmpty);
    c.getReply = DioException(requestOptions: RequestOptions(path: 'x'));
    expect((await CampaignsRepository(client: c).fetchCampaigns(storeId: 's1')).failed, isTrue);
  });

  test('campaign row (model fields; no live campaign to verify against)', () {
    final m = CampaignModel.fromJson({'_id': 'c1', 'name': 'Back to school', 'status': 'active', 'discountType': 'percentage', 'discountValue': 20});
    expect(m.discountLabel, '20% OFF');
  });
}
