import 'package:book_store_app/app/data/models/platform_plans/platform_subscription_model.dart';
import 'package:book_store_app/app/data/repositories/platform_plans_repository.dart';
import 'package:book_store_app/app/modules/seller/utils/plan_lapse.dart';
import 'package:book_store_app/app/services/account_switch_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real GET /api/platform-plans/:storeId (test store, 2026-11-17), trimmed;
/// `status` is swapped per test (the live value is 'trialing').
Map<String, dynamic> _plan(String status) => {
      '_id': '6af44c0a93ccfa01f3f8c75c',
      'storeId': '6af44c0893ccfa01f3f8c75b',
      'platformPlanId': '6ac5fdb4f11de1806ef4e8a2',
      'billingInterval': 'monthly',
      'amountUSD': 0,
      'status': status,
      'trialEndsAt': '2026-11-26T11:05:45.962Z',
      'currentPeriodEnd': '2026-12-11T11:05:45.962Z',
      'nextBillingDate': '2026-12-11T11:05:45.962Z',
      'canceledAt': null,
      'totalPaidUSD': 0,
      'creditBalanceUSD': 0,
      'plan': {
        '_id': '6ac5fdb4f11de1806ef4e8a2',
        'name': 'Free Trial',
        'isFree': true,
        'trialDays': 15,
      },
    };

class _FakePlans extends PlatformPlansRepository {
  _FakePlans(this.status);
  final String? status;
  int calls = 0;

  @override
  Future<PlatformSubscriptionModel?> getStorePlan(String storeId) async {
    calls++;
    return status == null ? null : PlatformSubscriptionModel.fromJson(_plan(status!));
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'store_id': 's1'});
    PlanGate.clearCache();
  });

  test('expired, past_due and canceled lapse; trialing and active do not', () {
    for (final s in ['expired', 'past_due', 'canceled']) {
      expect(PlanLapse.isLapsed(s), isTrue, reason: s);
    }
    for (final s in ['trialing', 'active', null]) {
      expect(PlanLapse.isLapsed(s), isFalse, reason: '$s');
    }
  });

  test('PlanGate reads data.status of the store plan and caches it', () async {
    final repo = _FakePlans('past_due');
    final first = await PlanGate.check(repository: repo);
    final second = await PlanGate.check(repository: repo);
    expect(first.lapsed, isTrue);
    expect(first.planName, 'Free Trial');
    expect(second.status, 'past_due');
    expect(repo.calls, 1);
    await PlanGate.check(force: true, repository: repo);
    expect(repo.calls, 2);
  });

  test('live trialing plan does not block', () async {
    final c = await PlanGate.check(repository: _FakePlans('trialing'));
    expect(c.lapsed, isFalse);
  });

  test('no plan (200 with data null) does not block', () async {
    final c = await PlanGate.check(repository: _FakePlans(null));
    expect(c.lapsed, isFalse);
    expect(c.status, isNull);
  });

  test('free-trial-eligibility live shape', () {
    final e = AccountEligibility.fromJson({
      'success': true,
      'data': {
        'eligible': false,
        'trialUsedAt': '2026-11-11T11:05:45.962Z',
        'hasSellerAccount': true,
        'hasBuyerAccount': true,
      },
    });
    expect(e.hasBuyerAccount, isTrue);
    expect(e.hasSellerAccount, isTrue);
    expect(e.eligible, isFalse);
    expect(e.trialUsedAt, DateTime.parse('2026-11-11T11:05:45.962Z'));
  });
}
