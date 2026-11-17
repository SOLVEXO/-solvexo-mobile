import 'package:book_store_app/app/data/models/finance/finance_dashboard_model.dart';
import 'package:book_store_app/app/modules/seller/utils/store_currency.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:flutter_test/flutter_test.dart';

// Real GET /api/finance/:storeId/dashboard for the PKR test store
// (2026-11-17): one empty USD wallet (created by a USD payout-schedule read).
Map<String, dynamic> _dashboard({double usdAvailable = 0}) => {
      'wallets': [
        {
          'currency': 'USD',
          'availableBalance': usdAvailable,
          'pendingBalance': 0,
          'isFlaggedForReview': false,
          'flaggedReason': null,
          'nextPayout': {'pendingAmount': null, 'scheduledAt': null, 'method': null},
          'summary': {'thisMonthRevenue': 0, 'revenueGrowthPercent': 0, 'platformFees': 0, 'totalPaidOut': 0, 'pendingTax': 0},
          'payoutSchedule': {'frequency': 'monthly', 'isEnabled': true, 'minimumAmount': 5, 'nextPayoutAt': null},
        }
      ],
      'feeBreakdown': {'transactionFee': '20% digital, 10% physical'},
      'platformFeeBreakdown': {'platformFee': '20% digital, 10% physical'},
    };

void main() {
  tearDown(() => StoreCurrency.code.value = '');

  test('PKR store: the empty USD wallet is hidden, PKR is shown on its own', () {
    StoreCurrency.code.value = 'PKR';
    final c = SellerFinanceController()..dashboard.value = FinanceDashboardModel.fromJson(_dashboard());
    expect(c.availableCurrencies, ['PKR']);
    final pkr = c.dashboard.value.walletFor('PKR');
    expect(pkr.currency, 'PKR', reason: 'never the USD wallet in its place');
    expect(pkr.availableBalance, 0);
  });

  test('a wallet with money in another currency is still shown, separately', () {
    StoreCurrency.code.value = 'PKR';
    final c = SellerFinanceController()
      ..dashboard.value = FinanceDashboardModel.fromJson(_dashboard(usdAvailable: 12.5));
    expect(c.availableCurrencies, ['PKR', 'USD']);
    expect(c.dashboard.value.walletFor('USD').availableBalance, 12.5);
  });

  test('platform fee wording comes from platformFeeBreakdown', () {
    final d = FinanceDashboardModel.fromJson(_dashboard());
    expect(d.feeBreakdown.asEntries.map((e) => e.key), contains('Platform fee'));
  });
}
