import 'package:book_store_app/app/data/models/refund_request_model.dart';
import 'package:book_store_app/app/data/models/return_reasons.dart';
import 'package:book_store_app/app/data/repositories/order_repository.dart';
import 'package:book_store_app/app/data/repositories/refund_request_repository.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/refund_request/controllers/refund_request_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Backend 5adba44: one reason list, note 20-1000, <= 4 photos;
// return = POST orders/return-request/:orderId, refund = POST refund-request.
class _Refunds extends RefundRequestRepository {
  final sent = <Map<String, dynamic>>[];
  @override
  Future<List<RefundRequestModel>> listForOrder(String orderId) async => [
        RefundRequestModel.fromJson({
          '_id': 'r1', 'orderId': 'o1', 'sellerOrderId': 's1', 'storeId': 'st', 'itemIds': ['old'], 'reason': 'Item arrived damaged',
          'reasonCode': 'damaged', 'note': 'The cover was torn when it arrived.', 'status': 'rejected',
          'resolutionNotes': 'The photos show no damage at all.', 'createdAt': '2026-11-10T10:00:00Z',
          'history': [
            {'status': 'requested', 'at': '2026-11-10T10:00:00Z', 'by': 'u', 'byRole': 'user'},
            {'status': 'rejected', 'at': '2026-11-11T10:00:00Z', 'by': 's', 'byRole': 'seller', 'note': 'The photos show no damage at all.'},
          ],
        }),
      ];
  @override
  Future<bool> create({required String orderId, required String sellerOrderId, required List<String> itemIds, required String reasonCode, required String note, List<String> evidenceImages = const []}) async {
    sent.add({'kind': 'refund', 'itemIds': itemIds, 'reasonCode': reasonCode, 'note': note, 'evidenceImages': evidenceImages});
    return true;
  }
}

class _Orders extends OrderRepository {
  final sent = <Map<String, dynamic>>[];
  @override
  Future<bool> requestReturn({required String orderId, required List<String> itemIds, required String reasonCode, required String note, List<String> evidenceImages = const []}) async {
    sent.add({'kind': 'return', 'itemIds': itemIds, 'reasonCode': reasonCode});
    return true;
  }
}

OrderModel _order() => OrderModel.fromJson({
      'orderId': 'o1', 'orderNumber': 'ORD-1', 'orderStatus': 'delivered', 'paymentStatus': 'paid', 'paymentType': 'cash_on_delivery',
      'isPaid': true, 'totalAmount': 800, 'currency': 'PKR', 'createdAt': '2026-11-05T05:15:26.555Z',
      'stores': [
        {
          'storeId': 'st', 'sellerOrderId': 's1', 'storeName': 'Store', 'status': 'delivered', 'fulfillmentType': 'physical',
          'items': [
            {'itemId': 'i1', 'productId': 'p1', 'name': 'English Book', 'type': 'physical', 'quantity': 1, 'price': 500, 'totalPrice': 500, 'returnStatus': 'none'},
            {'itemId': 'i2', 'productId': 'p2', 'name': 'Worksheets', 'type': 'digital', 'quantity': 1, 'price': 300, 'totalPrice': 300, 'returnStatus': 'none'},
            {'itemId': 'old', 'productId': 'p3', 'name': 'Old', 'type': 'physical', 'quantity': 1, 'price': 1, 'totalPrice': 1, 'returnStatus': 'none'},
          ],
        }
      ],
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);

  test('one reason list (server codes) and note rule', () {
    expect(kReturnReasons.map((r) => r.$1), ['damaged', 'missing_pages', 'printing_error', 'wrong_item', 'wrong_edition_or_class', 'not_as_described', 'digital_not_working', 'other']);
    expect(ReturnRules.note('too short'), isNotNull);
    expect(ReturnRules.note('x' * 1001), isNotNull);
    expect(ReturnRules.note('The book arrived with a torn cover.'), isNull);
    expect(returnReasonLabel('incomplete'), contains('Incomplete'), reason: 'legacy code is still shown');
  });

  test('status: rejected request with the seller reason and timeline', () async {
    final c = RefundRequestController(refunds: _Refunds(), orders: _Orders(), order: _order());
    c.onInit();
    await c.loadExistingRequests();
    final r = c.existingRequests.single;
    expect(r.isRejected, isTrue);
    expect(r.resolutionNotes, contains('no damage'));
    expect(r.history.map((h) => h['status']), ['requested', 'rejected']);
    expect(c.returnableItems.map((i) => i.itemId), ['i1', 'i2', 'old'], reason: 'a rejected request frees its items');
  });

  test('physical items can be sent back; digital ones are refund only', () async {
    final refunds = _Refunds(), orders = _Orders();
    final c = RefundRequestController(refunds: refunds, orders: orders, order: _order());
    c.onInit();
    await c.loadExistingRequests();
    c.toggleItem('i1');
    expect(c.canSendBack, isTrue);
    c.kind.value = 'return';
    c.reasonCode.value = 'damaged';
    c.noteController.text = 'The book arrived with a torn cover.';
    await c.submit();
    expect(orders.sent.single, {'kind': 'return', 'itemIds': ['i1'], 'reasonCode': 'damaged'});

    c.toggleItem('i2');
    expect(c.selectionIsDigital, isTrue);
    expect(c.canSendBack, isFalse);
    expect(c.reasons.map((r) => r.$1), contains('digital_not_working'));
    c.reasonCode.value = 'digital_not_working';
    c.noteController.text = 'The PDF does not open on any device.';
    expect(c.validate(), isTrue);
    await c.submit();
    expect(refunds.sent.single['reasonCode'], 'digital_not_working');
    expect(refunds.sent.single['evidenceImages'], isEmpty);
  });
}
