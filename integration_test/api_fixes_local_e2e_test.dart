// ignore_for_file: avoid_print
// Local end-to-end check of the API fixes, driven through the APP's own code
// (repositories / controllers -> BaseClient -> DioService with its
// interceptors -> AppPreferences session storage) against a LOCAL API.
//
// Run (iOS simulator; never against production):
//   flutter test integration_test/api_fixes_local_e2e_test.dart \
//     -d <simulator-id> --dart-define=API_BASE_URL=http://localhost:3099
//
// Accounts and ids are the local seed (buyer / buyer2 / seller / admin on
// *.edudeen.test). Only the admin approval of a bank proof uses a raw Dio
// call (the app has no admin UI); every other step goes through app classes.

import 'dart:convert';
import 'dart:io';

import 'package:book_store_app/app/data/repositories/auth_repository.dart';
import 'package:book_store_app/app/data/repositories/buyer_extras_repository.dart';
import 'package:book_store_app/app/data/repositories/cart_repository.dart';
import 'package:book_store_app/app/data/repositories/checkout_repository.dart';
import 'package:book_store_app/app/data/repositories/library_repository.dart';
import 'package:book_store_app/app/data/repositories/manual_transfer_repository.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/data/repositories/premium_repository.dart';
import 'package:book_store_app/app/data/repositories/product_repository.dart';
import 'package:book_store_app/app/data/repositories/rating_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_finance_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_orders_repository.dart';
import 'package:book_store_app/app/data/repositories/seller_repository.dart';
import 'package:book_store_app/app/data/repositories/shipping_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/app/modules/refund_request/controllers/refund_request_controller.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/app/network/api_constaints.dart';
import 'package:book_store_app/app/network/base_client.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/main.dart' as app;
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Local seed ────────────────────────────────────────────────────────────────
const _buyer = ('buyer@edudeen.test', 'Buyer#Local123', 'user');
// Second buyer: does the free/bank digital checkouts (F2, F5) and reports the
// review (F7). It must not own the free/paid digital products yet (the API
// refuses to sell an item already in the library), so a re-run needs a fresh
// account: --dart-define=E2E_BUYER2_EMAIL=... --dart-define=E2E_BUYER2_PASSWORD=...
const _buyer2 = (
  String.fromEnvironment('E2E_BUYER2_EMAIL', defaultValue: 'buyer2@edudeen.test'),
  String.fromEnvironment('E2E_BUYER2_PASSWORD', defaultValue: 'Buyer2#Local123'),
  'user',
);
const _seller = ('seller@edudeen.test', 'Seller#Local123', 'seller');
const _admin = ('admin@edudeen.test', 'Admin#Local123', 'admin');

const storeId = '6b03e870286226ffe22c7629';
const pFree = '6b03e89b286226ffe22c762e', vFree = '6b03e89b286226ffe22c762f';
const pPaid = '6b03e8a2286226ffe22c7631', vPaid = '6b03e8a2286226ffe22c7632';
const pPhys = '6b03e8ab286226ffe22c7634', vPhys = '6b03e8ab286226ffe22c7635';
const zoneId = '6b03e84e286226ffe22c7628';
const addressId = '6b03e8c9286226ffe22c7641';
const existingReviewId = '6b03e988286226ffe22c76a3';

const _receiptPngB64 =
    'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAIAAAAlC+aJAAAAX0lEQVR4nO3PMQ0AMAzAsPJHOwgFscOqFCNI5h03OuBXA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA1oDWgNaA9oC0FECpMKDuO0AAAAASUVORK5CYII=';

/// A logged-in session as the app stores it after AuthRepository.login.
class _Session {
  _Session(this.access, this.refresh, this.userId, this.name, this.email, this.role);
  final String access, refresh, userId, name, email, role;

  /// Switch the app to this account exactly the way login persists it.
  Future<void> activate() async {
    await AppPreferences.setTokens(accessToken: access, refreshToken: refresh);
    await AppPreferences.saveUserData(userId: userId, name: name, email: email, role: role);
  }
}

final results = <String, List<String>>{}; // flow -> evidence lines ('FAIL: ...' marks failure)
void note(String flow, String line) {
  (results[flow] ??= []).add(line);
  print('[$flow] $line');
}

void check(String flow, bool ok, String what) => note(flow, ok ? 'ok: $what' : 'FAIL: $what');

Future<void> guard(String flow, Future<void> Function() body) async {
  try {
    await body();
  } catch (e, st) {
    note(flow, 'FAIL: exception $e');
    print(st.toString().split('\n').take(6).join('\n'));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpUntil(WidgetTester tester, bool Function() cond, {Duration timeout = const Duration(seconds: 30)}) async {
    final end = DateTime.now().add(timeout);
    while (!cond()) {
      if (DateTime.now().isAfter(end)) throw 'timed out waiting';
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('API fixes: 7 flows through the app code against the local API', (tester) async {
    expect(ApiConstants.isProduction, isFalse, reason: 'must run with --dart-define=API_BASE_URL=<local>');
    expect(ApiConstants.baseUrl.contains('localhost') || ApiConstants.baseUrl.contains('127.0.0.1'), isTrue);

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('has_seen_onboarding', true);

    app.main();
    await tester.pump();
    await pumpUntil(tester, () => Get.currentRoute == Routes.mainHome || Get.currentRoute == Routes.onboarding,
        timeout: const Duration(seconds: 45));
    print('App booted on ${Get.currentRoute} against ${ApiConstants.baseUrl}');

    final auth = AuthRepository();
    Future<_Session> login((String, String, String) acc) async {
      final r = await auth.login(email: acc.$1, password: acc.$2, role: acc.$3);
      if (r == null) throw 'login failed for ${acc.$1}';
      // Stored by the app's login path: verify the session landed in AppPreferences.
      final stored = await AppPreferences.getAccessTokenAsync();
      if (stored != r.token.accessToken) throw 'login did not persist the access token';
      if (await AppPreferences.getUserRole() != r.user.role) throw 'login did not persist the role';
      return _Session(r.token.accessToken, r.token.refreshToken, r.user.id, r.user.name, r.user.email, r.user.role);
    }

    final checkout = CheckoutRepository();
    final cart = CartRepository();
    final orders = OrderRepository();
    final sellerOrders = SellerOrdersRepository();
    final finance = SellerFinanceRepository();

    // ── BUYER ────────────────────────────────────────────────────────────────
    final buyer = await login(_buyer);
    print('buyer logged in: ${buyer.userId} role=${buyer.role}');

    // Flow 1: Premium member price
    await guard('F1', () async {
      final me = await PremiumRepository().me();
      check('F1', me.isPremium, 'PremiumRepository.me() isPremium=${me.isPremium} membership=${me.membership?['status']}');
      final pd = await ProductRepository().getProductDetailById(pPaid);
      final v = pd?.defaultVariant;
      check('F1', v != null && v.price == 500 && v.premiumPrice == 425,
          'getProductDetailById variant price=${v?.price} premiumPrice=${v?.premiumPrice} ${v?.currency}');
      // The product screen itself: controller + the "Member price" chip.
      Get.toNamed(Routes.productDetailsView, arguments: pPaid);
      await pumpUntil(tester, () =>
          Get.isRegistered<ProductDetailController>() && Get.find<ProductDetailController>().selectedVariant.value != null);
      final c = Get.find<ProductDetailController>();
      check('F1', c.selectedVariant.value?.premiumPrice == 425,
          'ProductDetailController.selectedVariant.premiumPrice=${c.selectedVariant.value?.premiumPrice}');
      await tester.pump(const Duration(milliseconds: 500));
      final chip = find.byKey(const Key('memberPrice'));
      String chipText = '';
      if (chip.evaluate().isNotEmpty) {
        final texts = find.descendant(of: chip, matching: find.byType(Text)).evaluate().map((e) => (e.widget as Text).data ?? '');
        chipText = texts.join(' ');
      }
      check('F1', chip.evaluate().isNotEmpty && chipText.contains('425'), 'product screen shows member price chip "$chipText"');
      Get.back();
      await tester.pump(const Duration(milliseconds: 500));
    });

    // Flow 6 (read part): shipping zones through the app
    await guard('F6', () async {
      final zones = await ShippingRepository().getShippingZones();
      final z = zones.where((z) => z.id == zoneId).firstOrNull;
      check('F6', z != null && z.shippingPrice == 250, 'getShippingZones -> ${zones.length} zone(s), $zoneId ${z?.city} fee=${z?.shippingPrice}');
    });

    Future<({String checkoutId, double fee, double total, List<String> allowed})> physicalCheckout(String flow) async {
      await cart.clearCart();
      await cart.addToCart(productId: pPhys, productVariantId: vPhys);
      final co = await checkout.createCheckout(
        items: [{'productId': pPhys, 'variantId': vPhys}],
        addressId: addressId,
        shippingZoneId: zoneId,
      );
      if (!co.success || co.data == null) throw 'createCheckout failed: ${co.message}';
      final d = co.data!;
      note(flow, 'checkout ${d.checkout.id} zone=${d.checkout.shippingZoneId} fee=${d.summary.shippingFee} '
          'subtotal=${d.summary.subtotal} total=${d.summary.totalAmount} allowed=${d.allowedPaymentMethods}');
      return (checkoutId: d.checkout.id, fee: d.summary.shippingFee, total: d.summary.totalAmount, allowed: d.allowedPaymentMethods);
    }

    // Flow 6: create-checkout with shippingZoneId
    await guard('F6', () async {
      final c = await physicalCheckout('F6');
      check('F6', c.fee == 250, 'shippingFee=${c.fee} (expected 250), total=${c.total}');
    });

    // Flow 3: COD order -> cancel in the app
    await guard('F3', () async {
      final c = await physicalCheckout('F3');
      check('F3', c.allowed.contains('cash_on_delivery'), 'COD allowed');
      final r = await checkout.placeCodOrder(c.checkoutId);
      check('F3', r.success && r.orderIds.isNotEmpty, 'placeCodOrder orderIds=${r.orderIds}');
      final oid = r.orderIds.first;
      final ok = await orders.cancelOrder(oid, reason: 'Cancelled by customer');
      check('F3', ok, 'OrderRepository.cancelOrder($oid) -> $ok');
      final mine = await orders.getMyOrders(limit: 50);
      final o = mine.where((o) => o.orderId == oid).firstOrNull;
      check('F3', o != null && (o.orderStatus == 'cancelled' || o.stores.every((s) => s.status == 'cancelled')),
          'my-orders shows $oid orderStatus=${o?.orderStatus} stores=${o?.stores.map((s) => s.status).toList()}');
      // Also try the repository's single-order read (sends no token).
      try {
        final one = await orders.getOrderById(oid);
        note('F3', 'info: getOrderById -> ${one?.orderStatus}');
      } on DioException catch (e) {
        note('F3', 'BUG: OrderRepository.getOrderById -> HTTP ${e.response?.statusCode} ${e.response?.data}');
      }
    });

    // Flow 4a: physical COD order to be fulfilled
    String? codOrderId;
    await guard('F4', () async {
      final c = await physicalCheckout('F4');
      final r = await checkout.placeCodOrder(c.checkoutId);
      check('F4', r.success && r.orderIds.isNotEmpty, 'placeCodOrder orderIds=${r.orderIds}');
      codOrderId = r.orderIds.first;
    });

    // Flow 7a: buyer reviews the free product (needed for a fresh review to report)
    String? newReviewId;
    await guard('F7', () async {
      final rating = RatingRepository();
      String? own(List l) => l.where((r) => (r.productId ?? r.product?.productId) == pFree).map((r) => r.reviewId as String).firstOrNull;
      newReviewId = own(await rating.fetchMyReviews());
      if (newReviewId != null) {
        note('F7', 'buyer already has review $newReviewId on the free product (earlier run) - reusing it');
        return;
      }
      final rv = await rating.addReview(
        productId: pFree,
        productVariantId: vFree,
        
        rating: 4,
        comment: 'Good free worksheets for practising salah steps with kids.',
      );
      note('F7', 'buyer addReview(free product) success=${rv.success} notEligible=${rv.notEligible} msg=${rv.message}');
      final mine = await rating.fetchMyReviews();
      newReviewId = own(mine);
      check('F7', newReviewId != null, 'buyer review on free product id=$newReviewId (my reviews: ${mine.length})');
    });

    // ── SELLER ───────────────────────────────────────────────────────────────
    final seller = await login(_seller);
    print('seller logged in: ${seller.userId} role=${seller.role}');
    final stores = await SellerRepository().getMyStores();
    final sid = stores.firstOrNull?.id;
    print('seller stores: ${stores.map((s) => s.id).toList()}');
    if (sid != null) await AppPreferences.saveStoreId(sid);

    Future<String> walletLine() async {
      final s = await finance.getEarningsSummary(storeId);
      final dash = await finance.getDashboard(storeId);
      final w = dash.wallets.where((w) => w.currency == 'PKR').firstOrNull;
      return 'earnings-summary ${s.currency} available=${s.available} clearing=${s.clearing} expected=${s.expected.amount} '
          '| dashboard PKR available=${w?.availableBalance} pending=${w?.pendingBalance}';
    }

    // Flow 4b: ship -> deliver -> mark paid through the seller repositories
    await guard('F4', () async {
      check('F4', sid == storeId, 'getMyStores -> $sid');
      final list = await sellerOrders.fetchSellerOrders(storeId: storeId, tab: 'needs_action', limit: 50);
      final row = list.orders.where((o) => '${o['orderId'] ?? o['_id']}' == codOrderId).firstOrNull;
      check('F4', row != null, 'fetchSellerOrders(needs_action) contains $codOrderId (failed=${list.failed}, n=${list.orders.length}, counts=${list.counts})');
      final shipped = await sellerOrders.updateOrderStatus(
          orderId: codOrderId!, storeId: storeId, status: 'shipped', tracking: {'carrier': 'TCS', 'trackingNumber': 'TCS-APP-E2E-1'});
      check('F4', shipped, 'updateOrderStatus shipped -> $shipped');
      final delivered = await sellerOrders.updateOrderStatus(orderId: codOrderId!, storeId: storeId, status: 'delivered');
      check('F4', delivered, 'updateOrderStatus delivered -> $delivered');
      final paid = await sellerOrders.markOrderPaid(codOrderId!, storeId: storeId);
      check('F4', paid, 'markOrderPaid -> $paid');
    });

    String? walletBefore;
    await guard('F5', () async {
      walletBefore = await walletLine();
      note('F5', 'seller wallet BEFORE bank approval (after F4 COD paid): $walletBefore');
    });

    // ── BUYER2 (does not own the digital products yet) ─────────────────────
    final buyer2 = await login(_buyer2);
    print('buyer2 logged in: ${buyer2.userId}');
    String? freeOrderId;
    // Flow 2 (buyer2): free checkout -> library -> ZIP
    await guard('F2', () async {
      await cart.clearCart();
      await cart.addToCart(productId: pFree, productVariantId: vFree);
      final co = await checkout.createCheckout(items: [{'productId': pFree, 'variantId': vFree}]);
      check('F2', co.success && co.data != null, 'createCheckout success=${co.success} msg=${co.message}');
      final d = co.data!;
      check('F2', d.allowedPaymentMethods.contains('free') && d.summary.totalAmount == 0,
          'checkout ${d.checkout.id} allowed=${d.allowedPaymentMethods} total=${d.summary.totalAmount}');
      final pay = await checkout.placeFreeOrder(d.checkout.id);
      check('F2', pay.success && pay.orderIds.isNotEmpty, 'placeFreeOrder success=${pay.success} orderIds=${pay.orderIds}');
      freeOrderId = pay.orderIds.firstOrNull;
      final files = await LibraryRepository().fetchFiles();
      final f = files.where((x) => x.orderId == freeOrderId && x.productId == pFree).firstOrNull;
      check('F2', f != null && f.isPaid && f.fileCount == 2,
          'library has order $freeOrderId: paid=${f?.isPaid} fileCount=${f?.fileCount} format=${f?.deliveryFormat} (library size ${files.length})');
      final url = await BuyerExtrasRepository().zipLink(freeOrderId!, pFree);
      note('F2', 'zipLink -> ${url.split('?').first}?token=…');
      check('F2', url.startsWith(ApiConstants.baseUrl), 'zip URL is on the configured API host');
      // The app hands this URL to the browser (launchUrl); fetch it here instead.
      final res = await BaseClient().get(url, responseType: ResponseType.bytes);
      final bytes = (res.data as List).cast<int>();
      final isZip = bytes.length > 4 && bytes[0] == 0x50 && bytes[1] == 0x4B;
      check('F2', res.statusCode == 200 && isZip,
          'ZIP download status=${res.statusCode} bytes=${bytes.length} magic=PK:$isZip type=${res.headers.value('content-type')}');
    });

    // Flow 5a (buyer2): bank-proof checkout
    String? bankCheckoutId, proofId;
    List<String> bankOrderIds = [];
    await guard('F5', () async {
      await cart.clearCart();
      await cart.addToCart(productId: pPaid, productVariantId: vPaid);
      final co = await checkout.createCheckout(items: [{'productId': pPaid, 'variantId': vPaid}]);
      check('F5', co.success, 'createCheckout success=${co.success} msg=${co.message}');
      final d = co.data!;
      bankCheckoutId = d.checkout.id;
      check('F5', d.allowedPaymentMethods.contains('manual_bank_transfer'),
          'checkout $bankCheckoutId total=${d.summary.totalAmount} ${d.checkout.currency} allowed=${d.allowedPaymentMethods}');
      final mt = ManualTransferRepository();
      final bank = await mt.getBankDetails(bankCheckoutId!);
      check('F5', bank != null, 'getBankDetails -> ${bank != null}');
      final file = File('${Directory.systemTemp.path}/receipt-${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(base64Decode(_receiptPngB64));
      note('F5', 'Idempotency-Key sent: ${ManualTransferRepository.manualProofKey(bankCheckoutId!, file)}');
      final sub = await mt.submitPayment(
        checkoutId: bankCheckoutId!,
        proofImage: file,
        transactionReference: 'TXN-APP-${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Test Buyer',
      );
      check('F5', sub.success && sub.proof != null,
          'submitPayment success=${sub.success} proof=${sub.proof?.id} status=${sub.proof?.status} amountPKR=${sub.proof?.amountPKR} orders=${sub.proof?.orderIds} msg=${sub.message}');
      proofId = sub.proof?.id;
      bankOrderIds = sub.proof?.orderIds ?? [];
      final before = await orders.getOrdersByCheckout(bankCheckoutId!);
      note('F5', 'before approval: by-checkout orders=${before.map((o) => '${o.orderId}:isPaid=${o.isPaid}/${o.paymentStatus}').toList()}');
    });

    // Flow 7b (buyer2): report the buyer's review twice
    await guard('F7', () async {
      final rating = RatingRepository();
      final old = await rating.reportReview(reviewId: existingReviewId, reasonCode: 'spam');
      note('F7', 'report $existingReviewId -> ok=${old.ok} alreadyReported=${old.alreadyReported} msg=${old.message}');
      check('F7', old.ok || old.alreadyReported, 'report of the seeded review accepted or 409 alreadyReported');
      final first = await rating.reportReview(reviewId: newReviewId!, reasonCode: 'spam');
      check('F7', first.ok || first.alreadyReported,
          'first report of $newReviewId -> ok=${first.ok} alreadyReported=${first.alreadyReported} msg=${first.message}'
          '${first.alreadyReported ? ' (re-run: was reported earlier)' : ''}');
      final second = await rating.reportReview(reviewId: newReviewId!, reasonCode: 'spam');
      check('F7', !second.ok && second.alreadyReported,
          'second report -> ok=${second.ok} alreadyReported=${second.alreadyReported} msg=${second.message}');
    });


    // ── ADMIN (raw: the app has no admin UI) ────────────────────────────────
    await guard('F5', () async {
      final raw = Dio(BaseOptions(baseUrl: ApiConstants.apiPrefix, validateStatus: (_) => true));
      final l = await raw.post('/auth/login', data: {'email': _admin.$1, 'password': _admin.$2, 'role': _admin.$3});
      final at = l.data['data']['token']['accessToken'] as String;
      final h = {'Authorization': 'Bearer $at'};
      final ra = await raw.post('/admin/reauth/verify-password', data: {'password': _admin.$2}, options: Options(headers: h));
      final reauth = '${ra.data['data']?['reauthToken']}';
      final ap = await raw.patch('/admin/manual-payments/$proofId/approve',
          options: Options(headers: {...h, 'X-Admin-Reauth': reauth}));
      check('F5', ap.statusCode == 200 && ap.data['success'] == true,
          'RAW admin approve proof $proofId -> HTTP ${ap.statusCode} status=${ap.data is Map ? (ap.data['data'] is Map ? ap.data['data']['status'] : ap.data['message']) : ap.data}');
    });

    await buyer2.activate();
    // Flow 5b (buyer2): order paid through the app's order reads
    await guard('F5', () async {
      final by = await orders.getOrdersByCheckout(bankCheckoutId!);
      check('F5', by.isNotEmpty && by.every((o) => o.isPaid),
          'getOrdersByCheckout -> ${by.map((o) => '${o.orderId}:isPaid=${o.isPaid}/${o.paymentStatus} total=${o.totalAmount} ${o.currency}').toList()}');
      final mine = await orders.getMyOrders(limit: 50);
      final o = mine.where((o) => bankOrderIds.contains(o.orderId)).firstOrNull;
      check('F5', o != null && o.isPaid, 'my-orders ${o?.orderId} isPaid=${o?.isPaid} paymentStatus=${o?.paymentStatus}');
      final p = await ManualTransferRepository().getProofStatus(proofId!);
      check('F5', p?.status == 'approved', 'getProofStatus -> ${p?.status}');
    });

    // ── BUYER again ──────────────────────────────────────────────────────────
    await buyer.activate();

    // Flow 4c: buyer refund request through the app's form controller
    RefundRequestController? form;
    await guard('F4', () async {
      final mine = await orders.getMyOrders(limit: 50);
      final OrderModel? o = mine.where((o) => o.orderId == codOrderId).firstOrNull;
      check('F4', o != null, 'buyer sees $codOrderId: isPaid=${o?.isPaid} stores=${o?.stores.map((s) => s.status).toList()}');
      form = Get.put(RefundRequestController(order: o), tag: 'e2e');
      await pumpUntil(tester, () => !form!.isLoadingStatuses.value);
      check('F4', form!.eligibleStores.length == 1, 'form eligibleStores=${form!.eligibleStores.length}');
      final item = form!.returnableItems.first;
      form!.toggleItem(item.itemId);
      form!.kind.value = 'refund';
      form!.reasonCode.value = 'damaged';
      form!.noteController.text = 'The hardcover spine arrived cracked and the first pages are torn.';
      await form!.submit();
      final req = form!.existingRequests.where((r) => r.itemIds.contains(item.itemId)).firstOrNull;
      check('F4', req != null && req.isPending, 'refund request ${req?.id} status=${req?.status} reasonCode=${req?.reasonCode}');
    });

    // ── SELLER again ─────────────────────────────────────────────────────────
    await seller.activate();
    const rejectReason = 'Photos show the parcel was intact at dispatch; please contact the courier.';
    await guard('F4', () async {
      final sr = Get.put(SellerReturnsController(), tag: 'e2e');
      await pumpUntil(tester, () => !sr.isLoading.value);
      check('F4', !sr.loadFailed.value, 'SellerReturnsController loaded ${sr.items.length} rows');
      final row = sr.items.where((i) => i.orderId == codOrderId && i.isOpen).firstOrNull;
      check('F4', row != null, 'seller sees open ${row?.source} request ${row?.requestId} for $codOrderId');
      final ok = await sr.reject(row!, rejectReason);
      check('F4', ok, 'SellerReturnsController.reject -> $ok');
      Get.delete<SellerReturnsController>(tag: 'e2e');
    });

    // Flow 5c: seller wallet after approval
    await guard('F5', () async {
      final after = await walletLine();
      note('F5', 'seller wallet AFTER approval: $after');
      check('F5', after != walletBefore, 'seller wallet moved after the bank approval (pending/clearing should grow by the sale net of fees)');
    });

    // ── BUYER again: sees the reason ─────────────────────────────────────────
    await buyer.activate();
    await guard('F4', () async {
      await form!.loadExistingRequests();
      final req = form!.existingRequests.firstOrNull;
      check('F4', req != null && req.isRejected && (req.resolutionNotes ?? '') == rejectReason,
          'buyer reads refund request ${req?.id}: status=${req?.status} resolutionNotes="${req?.resolutionNotes}"');
      Get.delete<RefundRequestController>(tag: 'e2e');
    });

    // ── Summary ──────────────────────────────────────────────────────────────
    print('\n========== SUMMARY ==========');
    for (final f in ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7']) {
      final lines = results[f] ?? const ['FAIL: no steps ran'];
      final failed = lines.any((l) => l.startsWith('FAIL'));
      print('$f ${failed ? 'FAIL' : 'PASS'}');
      for (final l in lines) {
        print('   $l');
      }
    }
    print('=============================\n');
    final failedFlows = [
      for (final f in ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7'])
        if ((results[f] ?? const ['FAIL']).any((l) => l.startsWith('FAIL'))) f,
    ];
    expect(failedFlows, isEmpty, reason: 'failed flows: $failedFlows');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
