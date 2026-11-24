import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/cart_repository.dart';
import 'package:book_store_app/config/app_config.dart';
import 'package:book_store_app/app/modules/cart/controllers/cart_controller.dart';
import 'package:book_store_app/app/modules/cart/models/cart_response_model.dart';
import 'package:book_store_app/app/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Real GET /api/cart/unified for the test buyer (one physical + one digital
// line, 2026-11-18). get-cart without ?storeId returned items: [] for the
// same cart, which is why the app now reads the unified cart.
final _unified = jsonDecode(File('test/fixtures/cart_unified.json').readAsStringSync())['data'] as Map<String, dynamic>;

class _Repo extends CartRepository {
  final updates = <String>[];
  final removed = <String>[];

  @override
  Future<List<CartItem>?> removeFromCart(String productId, String productVariantId, {String? storeId}) async {
    removed.add(productId);
    return const <CartItem>[];
  }

  @override
  Future<CartResponseModel?> getCart() async => CartResponseModel.fromJson(_unified);

  @override
  Future<CartItem?> updateCartItem({
    required String? storeId,
    required String productId,
    required String productVariantId,
    required String action,
  }) async {
    updates.add('$storeId $productId $action');
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({'user_id': 'u1'});
  });

  test('unified cart: storeId and type on every line, grandTotal', () {
    final cart = CartResponseModel.fromJson(_unified);
    expect(cart.items, hasLength(2));
    expect(cart.items.every((i) => i.storeId == '6ad09d1e9d4a719f081652f4'), isTrue);
    final digital = cart.items.firstWhere((i) => i.isDigital);
    expect(digital.productType, 'digital', reason: 'read from `type`');
    expect(cart.items.where((i) => !i.isDigital).single.productType, 'physical');
    expect(cart.totalPrice, 850);
  });

  test('digital purchases off: digital lines are removed from the cart on load', () async {
    final repo = _Repo();
    final c = CartController(cartRepository: repo, wishlistController: WishlistController());
    await c.fetchCart();
    expect(c.cartItems.any((i) => AppFeatures.isDigitalType(i.productType)), isFalse);
    expect(c.cartItems.where((i) => !i.isDigital), hasLength(1), reason: 'physical line stays');
    expect(repo.removed, hasLength(1));
  }, skip: AppFeatures.digitalPurchases);

  test('AppFeatures blocks digital (and legacy educational) only while the flag is off', () {
    expect(AppFeatures.blocksPurchase('physical'), isFalse);
    expect(AppFeatures.blocksPurchase('digital'), !AppFeatures.digitalPurchases);
    expect(AppFeatures.blocksPurchase('educational'), !AppFeatures.digitalPurchases);
  });

  test('digital lines never send a quantity update; physical sends storeId', () async {
    final repo = _Repo();
    final c = CartController(cartRepository: repo, wishlistController: WishlistController());
    await c.fetchCart();
    final digital = c.cartItems.firstWhere((i) => i.isDigital);
    final physical = c.cartItems.firstWhere((i) => !i.isDigital);

    await c.increaseQuantity(digital.productId, digital.productVariantId);
    await c.decreaseQuantity(digital.productId, digital.productVariantId);
    expect(repo.updates, isEmpty);

    await c.increaseQuantity(physical.productId, physical.productVariantId);
    expect(repo.updates, ['6ad09d1e9d4a719f081652f4 ${physical.productId} increase']);
  }, skip: !AppFeatures.digitalPurchases);
}
