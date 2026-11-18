import 'package:book_store_app/app/data/models/store_banner/store_banner_model.dart';
import 'package:book_store_app/app/data/repositories/seller_finance_repository.dart';
import 'package:book_store_app/app/modules/seller_store_banners/controllers/seller_store_banners_controller.dart';
import 'package:book_store_app/app/modules/seller_store_banners/widgets/store_banner_form_sheet.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _Client extends BaseClient {
  dynamic patched;
  @override
  Future<Response> patch(String url, {dynamic data, Map<String, dynamic>? headers, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) async {
    patched = data;
    return Response(requestOptions: RequestOptions(path: url), statusCode: 200, data: {
      '_id': 'm1', 'type': 'bank_transfer', 'currency': 'PKR', 'bankName': 'X', 'accountLast4': '1234',
    });
  }
}

StoreBannerModel _banner(String id, String status) => StoreBannerModel(
      id: id, storeId: 's1', type: 'hero', imageUrl: 'https://example.com/a.jpg', linkType: 'external',
      order: 0, priority: 0, status: status,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('payout method edit always sends the method type (backend 5adba44)', () async {
    // Live: without type -> 400 ["type must be one of the following values: "];
    // with type -> passes validation.
    final c = _Client();
    final m = await SellerFinanceRepository(client: c).updatePayoutMethod('s1', 'm1', type: 'bank_transfer', bankName: 'X');
    expect(c.patched['type'], 'bank_transfer');
    expect(m, isNotNull);
  });

  test('banner slots: active + scheduled count, max 4', () {
    final c = SellerStoreBannersController();
    c.banners.assignAll([_banner('1', 'active'), _banner('2', 'scheduled'), _banner('3', 'paused'), _banner('4', 'active')]);
    expect(c.slotsUsed, 3);
    expect(c.slotsFull, isFalse);
    c.banners.add(_banner('5', 'scheduled'));
    expect(c.slotsFull, isTrue);
  });

  test('banner links offer only none / product / collection', () {
    expect(kBannerLinkTypes, ['none', 'product', 'collection']);
  });
}
