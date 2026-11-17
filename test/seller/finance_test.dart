import 'package:book_store_app/app/data/models/finance/earnings_models.dart';
import 'package:book_store_app/app/data/repositories/seller_finance_repository.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Real responses for the test store (2026-11-17).
const _summary = {
  'currency': 'PKR',
  'available': 0,
  'clearing': 0,
  'clearingReleaseAt': null,
  'expected': {
    'amount': 0, 'feeEstimate': 0, 'orders': 0, 'toShip': 0, 'openOrders': 0,
    'platformCollectedCod': 0, 'sellerCollectedCod': 0, 'skipped': 0,
    'feeEstimateOk': true, 'capped': false,
  },
  'commissionOwed': 0,
  'isFlaggedForReview': false,
  'nextPayoutDate': null,
  'payoutFrequency': 'monthly',
  'defaultMethod': null,
  'transactionCount': 0,
  'platformFees': {
    'digital': {'mode': 'percentage', 'value': 20},
    'physical': {'mode': 'percentage', 'value': 10},
  },
  'fallbackFeeRate': 0,
  'cardProcessing': {'percent': 2.9, 'fixedUSD': 0.3},
  'clearingDays': {'card': 14, 'other': 3},
  'generatedAt': '2026-11-17T12:02:02.579Z',
};

const _statement = {
  'month': '2026-11',
  'currency': 'PKR',
  'totals': {'orderCount': 0, 'gross': 0, 'platformFee': 0, 'processingFee': 0, 'refunds': 0, 'net': 0},
  'truncated': false, 'total': 0, 'page': 1, 'limit': 25, 'pages': 1, 'rows': [], 'payout': null,
};

class _Client extends BaseClient {
  final calls = <String, Map<String, dynamic>?>{};

  @override
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool requiresAuth = false,
    ResponseType? responseType,
  }) async {
    calls[url] = queryParameters;
    final ro = RequestOptions(path: url);
    if (url.endsWith('/earnings-summary')) return Response(requestOptions: ro, statusCode: 200, data: _summary);
    if (url.endsWith('/earnings-statement')) return Response(requestOptions: ro, statusCode: 200, data: _statement);
    if (url.endsWith('/fee-estimate')) {
      return Response(requestOptions: ro, statusCode: 200, data: {
        'currency': 'PKR', 'type': 'digital', 'price': 1000,
        'generatedAt': '2026-11-17T12:00:55.251Z', 'fee': 200, 'net': 800, 'reason': null,
      });
    }
    if (url.endsWith('/earnings-statement/download')) {
      return Response(
        requestOptions: ro,
        statusCode: 200,
        data: '"Statement 2026-11","PKR"\n'.codeUnits,
        headers: Headers.fromMap({
          'content-disposition': ['attachment; filename="earnings-2026-11-PKR.csv"'],
        }),
      );
    }
    throw DioException(requestOptions: ro, response: Response(requestOptions: ro, statusCode: 404));
  }
}

void main() {
  test('earnings-summary maps to the four hero tiles + fee config', () {
    final s = EarningsSummary.fromJson(Map<String, dynamic>.from(_summary));
    expect(s.currency, 'PKR');
    expect(s.available, 0);
    expect(s.clearing, 0);
    expect(s.clearingReleaseAt, isNull);
    expect(s.expected.openOrders, 0);
    expect(s.commissionOwed, 0);
    expect(s.platformFees['digital']!.label, '20% of the item price');
    expect(s.platformFees['physical']!.label, '10% of the item price');
    expect(s.clearingDaysCard, 14);
    expect(s.cardProcessingFixedUSD, 0.3);
  });

  test('statement totals', () {
    final st = EarningsStatement.fromJson(Map<String, dynamic>.from(_statement));
    expect(st.month, '2026-11');
    expect(st.orderCount, 0);
    expect(st.rows, isEmpty);
  });

  test('repository: statement month query, fee estimate from the server, download name', () async {
    final client = _Client();
    final repo = SellerFinanceRepository(client: client);
    await repo.getEarningsStatement('s1', '2026-10');
    expect(client.calls.entries.last.value, {'month': '2026-10'});

    final fee = await repo.getFeeEstimate('s1', price: 1000, type: 'digital');
    expect(fee.fee, 200);
    expect(fee.net, 800);
    expect(client.calls.entries.last.value, {'price': 1000, 'type': 'digital'});

    final file = await repo.downloadEarningsStatement('s1', month: '2026-11', format: 'csv');
    expect(file.fileName, 'earnings-2026-11-PKR.csv');
    expect(client.calls.entries.last.value, {'format': 'csv', 'month': '2026-11'});
  });

  test('fee estimate input validation', () {
    expect(SellerFinanceController.validateFeePrice(''), isNotNull);
    expect(SellerFinanceController.validateFeePrice('abc'), isNotNull);
    expect(SellerFinanceController.validateFeePrice('0'), isNotNull);
    expect(SellerFinanceController.validateFeePrice('1000'), isNull);
  });
}
