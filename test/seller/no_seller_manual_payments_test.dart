import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Seller direct bank transfer is retired: every /api/seller/manual-payments
// route answers 410 (backend fix #9). Buyers' /api/payment/manual-transfer
// (paid to Edudeen) is live and stays. The app must never call the seller one.
void main() {
  test('no seller manual-payments route anywhere in lib/', () {
    final hits = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
      final src = f.readAsStringSync();
      if (src.contains('seller/manual-payments') || src.contains('sellerManualPayment')) hits.add(f.path);
    }
    expect(hits, isEmpty);
  });
}
