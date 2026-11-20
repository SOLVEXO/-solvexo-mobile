import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/premium_repository.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/premium/controllers/premium_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// Live GET /api/premium/plans and /api/premium/me (test buyer, 2026-11-20).
dynamic _f(String n) => jsonDecode(File('test/fixtures/premium_$n.json').readAsStringSync())['data'];

class _Client extends BaseClient {
  final posts = <String, ({dynamic data, Map<String, dynamic>? headers})>{};
  @override
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true, Map<String, dynamic>? headers}) async {
    posts[url] = (data: data, headers: headers);
    return Response(requestOptions: RequestOptions(path: url), statusCode: 201, data: {'success': true, 'data': {'_id': 'pay1', 'status': 'pending'}});
  }
}

void main() {
  test('plans: server prices per interval and currency', () {
    final p = PremiumPlan(( _f('plans') as List).first as Map);
    expect(p.name, 'Edudeen Premium');
    expect(p.price('monthly', 'USD'), 7);
    expect(p.price('yearly', 'PKR'), 19352);
    expect(p.yearlySavingsPercent, 17);
    expect(p.benefits['childrenLimit'], 15);
  });

  test('me: not premium, children limit 8 from entitlements', () {
    final s = PremiumStatus(_f('me') as Map);
    expect(s.isPremium, isFalse);
    expect(s.childrenLimit, 8);
    expect(s.pendingPayment, isNull);
  });

  test('subscribe body and proof upload with an Idempotency-Key', () async {
    final c = _Client();
    final repo = PremiumRepository(client: c);
    await repo.subscribe('6ace2f3ee054cb47706096a7', 'yearly');
    expect(c.posts.entries.single.value.data, {'planId': '6ace2f3ee054cb47706096a7', 'interval': 'yearly'});

    final f = File('${Directory.systemTemp.path}/proof_test.jpg')..writeAsBytesSync([1, 2, 3]);
    await repo.uploadProof('pay1', f, reference: 'TX1');
    final proof = c.posts.entries.firstWhere((e) => e.key.endsWith('/payments/pay1/proof')).value;
    expect(proof.headers, {'Idempotency-Key': 'premium-proof:pay1'});
    expect(proof.data, isA<FormData>());
    expect((proof.data as FormData).fields.map((e) => e.key), contains('transactionReference'));
  });

  test('a proof photo is required', () {
    expect(PremiumController.validateProof(null), isNotNull);
  });

  test('member price only when the API sends premiumPrice', () {
    final base = {'_id': 'v1', 'productId': 'p1', 'price': 1000, 'stock': 3, 'images': [], 'createdAt': '2026-11-01T00:00:00Z', 'updatedAt': '2026-11-01T00:00:00Z'};
    expect(ProductVariant.fromJson(base).premiumPrice, isNull);
    expect(ProductVariant.fromJson({...base, 'premiumPrice': 816}).premiumPrice, 816);
  });
}
