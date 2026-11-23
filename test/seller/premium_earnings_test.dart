import 'package:book_store_app/app/data/models/finance/earnings_models.dart';
import 'package:book_store_app/app/data/repositories/seller_finance_repository.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/modules/seller_products/widgets/product_list_actions.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

// Backend fix #5: fee-estimate with premiumPercent returns a `premium` block
// (shape from the local jami-branch API spec, price 1000, seller 15 %,
// platform 5 %, premium fee 7 %).
const _premium = {
  'memberPrice': 800, 'sellerPercent': 15, 'platformPercent': 5, 'memberDiscountPercent': 20,
  'platformFunded': 50, 'saleValue': 850, 'feePercent': 7, 'fee': 59.5, 'net': 790.5,
};

class _Client extends BaseClient {
  final queries = <Map<String, dynamic>?>[];
  bool noMemberPrice = false;
  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    queries.add(queryParameters);
    final asked = queryParameters?.containsKey('premiumPercent') ?? false;
    return Response(requestOptions: RequestOptions(path: url), statusCode: 200, data: {
      'currency': 'PKR', 'type': 'digital', 'price': 1000, 'fee': 100, 'net': 900, 'reason': null,
      if (asked) 'premium': noMemberPrice ? null : _premium,
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });

  test('parses the premium block; absent vs null are told apart', () {
    final withP = FeeEstimate.fromJson({'currency': 'PKR', 'price': 1000, 'fee': 100, 'net': 900, 'premium': _premium});
    expect(withP.premiumAsked, isTrue);
    expect(withP.premium!.memberPrice, 800);
    expect(withP.premium!.net, 790.5);
    final none = FeeEstimate.fromJson({'currency': 'PKR', 'price': 1000, 'fee': 100, 'net': 900, 'premium': null});
    expect(none.premiumAsked, isTrue);
    expect(none.premium, isNull);
    final old = FeeEstimate.fromJson({'currency': 'PKR', 'price': 1000, 'fee': 100, 'net': 900});
    expect(old.premiumAsked, isFalse);
  });

  test('repository sends premiumPercent only when given', () async {
    final c = _Client();
    final repo = SellerFinanceRepository(client: c);
    await repo.getFeeEstimate('s1', price: 1000, type: 'digital');
    await repo.getFeeEstimate('s1', price: 1000, type: 'digital', premiumPercent: 15);
    expect(c.queries[0], {'price': 1000, 'type': 'digital'});
    expect(c.queries[1], {'price': 1000, 'type': 'digital', 'premiumPercent': 15});
  });

  testWidgets('offer sheet shows "Your earnings" at the member price for the typed percent', (tester) async {
    final c = _Client();
    const product = SellerProduct(id: 'p1', name: 'Worksheets', emoji: '', price: 1000, type: 'Digital', status: ProductStatus.active, sold: 0);
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: PremiumOfferSheet(
      controller: SellerProductsController(), product: product, finance: SellerFinanceRepository(client: c)))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('memberEarningsLine')), findsNothing);
    await tester.enterText(find.byKey(const Key('premiumPercent')), '15');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(c.queries.last?['premiumPercent'], 15);
    final line = tester.widget<Text>(find.byKey(const Key('memberEarningsLine'))).data!;
    expect(line, contains('790.5'));
    expect(line, contains('Edudeen adds'));
    c.noMemberPrice = true;
    await tester.enterText(find.byKey(const Key('premiumPercent')), '16');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(find.byKey(const Key('memberEarningsLine'))).data, contains('no member price applies'));
  });
}
