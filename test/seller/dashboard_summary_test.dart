import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/models/seller_dashboard_summary.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/dashboard_summary_cards.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Real GET /api/store/:storeId/dashboard-summary (test store, 2026-11-17).
  final body = jsonDecode(File('test/fixtures/dashboard_summary.json').readAsStringSync())
      as Map<String, dynamic>;

  test('summary: PKT period, PKR, free claims separate, action counts', () {
    final s = DashboardSummary.fromJson(body);
    expect(s.overview.timezone, 'Asia/Karachi');
    expect(s.overview.currency, 'PKR');
    expect(s.overview.freeClaims, 0);
    expect(s.today.freeClaims, 0);
    expect(s.actions.payoutMissing, 1);
    expect(s.actions.shippingActions, s.actions.ordersToShip + s.actions.ordersOverdue);
    expect(s.totalProducts, 0);
  });

  test('setup checklist: 5 steps, 20%, shipping not needed', () {
    final s = DashboardSummary.fromJson(body);
    expect(s.steps.map((e) => e.key), ['logo', 'banner', 'payout', 'first_product', 'shipping']);
    expect(s.checklistPercent, 20);
    expect(s.checklistDone, isFalse);
    final shipping = s.steps.last;
    expect(shipping.done, isTrue);
    expect(shipping.notNeeded, isTrue);
  });

  test('checklist web paths map to app screens', () {
    for (final p in ['settings', 'store-builder', 'finance', 'products/add']) {
      expect(DashboardChecklistCard.actionFor(p), isNotNull, reason: p);
    }
    expect(DashboardChecklistCard.actionFor('unknown'), isNull);
  });
}
