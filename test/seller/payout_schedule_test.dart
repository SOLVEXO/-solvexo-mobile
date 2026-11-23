import 'package:book_store_app/app/data/models/finance/payout_schedule_model.dart';
import 'package:book_store_app/app/data/repositories/seller_finance_repository.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Backend fix #11 (local jami-branch API): GET payout-schedule writes
// nothing and answers the default with `saved: false`; no currency = the
// store's own currency.
class _Client extends BaseClient {
  Map<String, dynamic>? query;
  @override
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters, dynamic data, bool requiresAuth = false, ResponseType? responseType}) async {
    query = queryParameters;
    return Response(requestOptions: RequestOptions(path: url), statusCode: 200, data: {
      'storeId': 's1', 'sellerId': 'u1', 'currency': 'PKR', 'frequency': 'monthly', 'dayOfWeek': 1, 'dayOfMonth': 1,
      'minimumAmount': 50, 'isEnabled': true, 'defaultPayoutMethodId': null, 'nextPayoutAt': '2026-12-01T00:00:00.000Z', 'saved': false,
    });
  }
}

void main() {
  test('default schedule is marked not saved; a stored one is saved', () {
    expect(PayoutScheduleModel.fromJson({'currency': 'PKR', 'saved': false}).saved, isFalse);
    expect(PayoutScheduleModel.fromJson({'currency': 'PKR', 'frequency': 'weekly'}).saved, isTrue);
  });

  test('no currency yet -> the query has none (server uses the store currency)', () async {
    final c = _Client();
    final s = await SellerFinanceRepository(client: c).getPayoutSchedule('s1', currency: '');
    expect(c.query, isEmpty);
    expect(s.currency, 'PKR');
    expect(s.saved, isFalse);
    await SellerFinanceRepository(client: c).getPayoutSchedule('s1', currency: 'PKR');
    expect(c.query, {'currency': 'PKR'});
  });
}
