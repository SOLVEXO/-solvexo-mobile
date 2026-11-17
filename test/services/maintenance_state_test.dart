import 'package:book_store_app/app/services/maintenance_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MaintenanceState.fromJson', () {
    test('503 body with scope=all blocks the buyer app', () {
      final s = MaintenanceState.fromJson({
        'maintenanceMode': true,
        'scope': 'all',
        'title': 'Back soon',
        'message': 'Upgrading',
      });
      expect(s.enabled, isTrue);
      expect(s.blocksBuyerApp, isTrue);
      expect(s.title, 'Back soon');
    });

    test('feature scope only blocks that feature', () {
      final s = MaintenanceState.fromJson({
        'maintenanceMode': true,
        'scope': 'feature:cart',
      });
      expect(s.blocksBuyerApp, isFalse);
      expect(s.blocksFeature('cart'), isTrue);
      expect(s.blocksFeature('search'), isFalse);
    });

    test('status endpoint shape wrapped in data with scopes list', () {
      final s = MaintenanceState.fromJson({
        'success': true,
        'data': {
          'enabled': true,
          'scopes': ['buyer', 'feature:search'],
          'scopeMessages': {'feature:search': 'Search is resting'},
        },
      });
      expect(s.blocksBuyerApp, isTrue);
      expect(s.messageFor('search'), 'Search is resting');
    });

    test('future startsAt is scheduled: nothing is blocked', () {
      final s = MaintenanceState.fromJson({
        'enabled': true,
        'scopes': ['all'],
        'startsAt': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      });
      expect(s.isScheduled, isTrue);
      expect(s.blocksBuyerApp, isFalse);
    });

    test('disabled config is off', () {
      final s = MaintenanceState.fromJson({'data': {'enabled': false}});
      expect(s.enabled, isFalse);
      expect(s.blocksBuyerApp, isFalse);
    });
  });
}
