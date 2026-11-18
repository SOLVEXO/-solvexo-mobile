import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/models/analytics/analytics_overview_model.dart';
import 'package:flutter_test/flutter_test.dart';

// Real GET /api/seller/analytics/overview?compareToPreviousPeriod=true for
// the test store (2026-11-18). Without the flag the *Change fields are absent.
void main() {
  final json = jsonDecode(File('test/fixtures/analytics_overview_compare.json').readAsStringSync())['data'] as Map<String, dynamic>;

  test('reads booked/collected and the change fields', () {
    final m = AnalyticsOverviewModel.fromJson(json);
    expect(m.currency, 'PKR');
    expect(m.bookedValueChangePercent, 0);
    expect(m.collectedChangePercent, 0);
    expect(m.totalOrdersChange, 0);
    expect(m.avgOrderValueChangePercent, 0);
  });

  test('no comparison -> nulls, not zeros', () {
    final m = AnalyticsOverviewModel.fromJson({...json}..removeWhere((k, _) => k.endsWith('Change') || k.endsWith('ChangePercent')));
    expect(m.bookedValueChangePercent, isNull);
    expect(m.totalOrdersChange, isNull);
  });

  test('percent null when the previous period was 0 (server percentChange)', () {
    final m = AnalyticsOverviewModel.fromJson({...json, 'bookedValue': 500, 'bookedValueChangePercent': null});
    expect(m.bookedValue, 500);
    expect(m.bookedValueChangePercent, isNull);
  });
}
