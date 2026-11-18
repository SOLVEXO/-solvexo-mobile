import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/seller_product_repository.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Client extends BaseClient {
  final calls = <String, dynamic>{};

  @override
  Future<Response> patch(String url, {dynamic data, Map<String, dynamic>? headers, Map<String, dynamic>? queryParameters, bool requiresAuth = true}) async {
    calls[url] = data;
    final ro = RequestOptions(path: url);
    if (url.endsWith('/bulk-status')) {
      // Real response for a draft (test store, 2026-11-17).
      return Response(requestOptions: ro, statusCode: 200, data: {
        'success': true,
        'message': '0 products deactivated, 1 skipped.',
        'data': {
          'updated': [],
          'skipped': [
            {
              'id': '6afc4ff81f2e13faea3e651c',
              'name': 'TEST DRAFT P2 products check - do not publish',
              'reason': 'Only a live or scheduled product can be deactivated.',
            }
          ],
          'changedMeanwhile': 0,
        },
      });
    }
    // stock/bulk and variant price: real success shapes.
    return Response(requestOptions: ro, statusCode: 200, data: {
      'success': true,
      'data': {'updated': 1, 'skipped': []},
    });
  }

  @override
  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters, bool requiresAuth = true, Map<String, dynamic>? headers}) async {
    calls[url] = data;
    return Response(requestOptions: RequestOptions(path: url), statusCode: 201, data: {
      'success': true,
      'message': url.contains('duplicate') ? 'Draft copy created' : 'Product updated successfully',
      'data': {'productId': 'copy1', 'slug': 'x-copy', 'name': 'X (copy)', 'status': 'draft'},
    });
  }
}

void main() {
  // Real GET getStoreInventory row of a test draft (2026-11-17).
  final row = jsonDecode(File('test/fixtures/inventory_row_draft.json').readAsStringSync())
      as Map<String, dynamic>;

  test('inventory row: raw status, plan pause, admin note, default variant', () {
    final p = SellerProduct.fromApiJson(row);
    expect(p.rawStatus, 'draft');
    expect(p.pausedByPlan, isFalse);
    expect(p.adminNote, isNull);
    expect(p.defaultVariantId, isNotNull);
    expect(p.qualityMissing, contains('Add photos'));
    expect(p.isLive, isFalse);

    final sentBack = SellerProduct.fromApiJson({
      ...row,
      'status': 'rejected',
      'reviewNote': 'Remove the phone number from the description',
    });
    expect(sentBack.needsChanges, isTrue);
    expect(sentBack.adminNote, 'Remove the phone number from the description');
    expect(SellerProduct.fromApiJson({...row, 'pausedByPlan': true}).pausedByPlan, isTrue);
  });

  test('tabs are the raw API statuses', () {
    expect(ProductsTab.values.map((t) => t.api),
        [null, 'active', 'pending_review', 'rejected', 'draft', 'inactive']);
    expect(ProductsTab.fromApi('rejected'), ProductsTab.needsChanges);
  });

  test('inline edit validation', () {
    expect(SellerProductsController.validatePrice('abc'), isNotNull);
    expect(SellerProductsController.validatePrice('-1'), isNotNull);
    expect(SellerProductsController.validatePrice('150'), isNull);
    expect(SellerProductsController.validateStock('1.5'), isNotNull);
    expect(SellerProductsController.validateStock('-1'), isNotNull);
    expect(SellerProductsController.validateStock('1000001'), isNotNull);
    expect(SellerProductsController.validateStock('9'), isNull);
  });

  test('repository: bulk-status returns the server skip reasons', () async {
    final client = _Client();
    final r = await SellerProductRepository(client: client)
        .setProductsActive(['6afc4ff81f2e13faea3e651c'], active: false);
    expect(r.updated, 0);
    expect(r.skipped.single, contains('Only a live or scheduled product can be deactivated.'));
    expect(client.calls.values.single, {'ids': ['6afc4ff81f2e13faea3e651c'], 'active': false});
  });

  test('repository: price, stock and duplicate bodies', () async {
    final client = _Client();
    final repo = SellerProductRepository(client: client);
    expect((await repo.setDigitalPrice('d1', 180)).ok, isTrue);
    expect((await repo.setVariantPrice('p1', 'v1', 550)).ok, isTrue);
    expect((await repo.setVariantStock('s1', 'v1', 9)).ok, isTrue);
    expect((await repo.duplicateProduct('d1')).ok, isTrue);
    final bodies = client.calls;
    expect(bodies.entries.firstWhere((e) => e.key.endsWith('/edit-product')).value, {'productId': 'd1', 'price': 180.0});
    expect(bodies.entries.firstWhere((e) => e.key.endsWith('/variants/v1')).value, {'price': 550.0});
    expect(bodies.entries.firstWhere((e) => e.key.endsWith('/stock/bulk')).value, {
      'storeId': 's1',
      'updates': [
        {'variantId': 'v1', 'stock': 9}
      ],
    });
    expect(bodies.keys, contains(predicate<String>((k) => k.endsWith('/products/duplicate/d1'))));
  });
}
