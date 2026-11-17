import 'package:book_store_app/app/modules/add_seller_product/controllers/add_seller_product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/seller_onboarding/controllers/seller_onboarding_controller.dart';
import 'package:book_store_app/app/modules/seller_products/controllers/seller_products_controller.dart';
import 'package:flutter_test/flutter_test.dart';

// Live API 2026-11-17: POST add-digital-product {productType:'educational'}
// -> 400 "Educational products are no longer available. Choose digital."
void main() {
  test('Add product offers no Educational type', () {
    expect(kProductTypes.map((t) => t.name), isNot(contains('Educational')));
    expect(ProductTypeOption.values.map((v) => v.name), isNot(contains('educational')));
  });

  test('onboarding offers physical + digital only; legacy store type reads as digital', () {
    expect(WhatYouSellOption.values.map((o) => o.apiValue),
        ['physical_products', 'digital_downloads']);
    expect('educational_resources'.asWhatYouSellOption, WhatYouSellOption.digitalDownloads);
  });

  test('seller list shows a legacy educational row as Digital', () {
    final p = SellerProduct.fromApiJson({
      'productId': 'p1',
      'name': 'Class 8 Urdu Grammar',
      'type': 'educational',
      'status': 'active',
      'price': 100,
    });
    expect(p.type, 'Digital');
  });

  test('buyer model treats legacy educational as digital', () {
    final p = ProductModel.fromJson({
      '_id': 'p1',
      'name': 'Class 8 Urdu Grammar',
      'type': 'educational',
      'variants': [],
    });
    expect(p.isEducational, isTrue);
    expect(p.isDigital, isTrue);
    expect(p.inStock, isTrue);
  });
}
