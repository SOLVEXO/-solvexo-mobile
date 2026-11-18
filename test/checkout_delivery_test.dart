import 'package:book_store_app/app/data/repositories/manual_transfer_repository.dart';
import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/app/modules/checkout/models/create_checkout_response.dart';
import 'package:book_store_app/app/modules/checkout/models/shipping_options_model.dart';
import 'package:book_store_app/app/modules/checkout/utils/checkout_delivery.dart';
import 'package:flutter_test/flutter_test.dart';

// Backend 5adba44: create-checkout takes addressId + shippingZoneId (zone
// required once any active zone exists); bank-details needs checkoutId.
ShippingZoneModel _zone(String id, {String status = 'active', bool deleted = false}) => ShippingZoneModel.fromJson({
      '_id': id, 'country': 'Pakistan', 'province': 'Punjab', 'city': 'Lahore', 'shippingPrice': 200,
      'estimatedDeliveryTime': '2-3 days', 'status': status, 'isDelete': deleted,
      'createdAt': '2026-11-01T00:00:00Z', 'updatedAt': '2026-11-01T00:00:00Z',
    });

AddressModel _addr(String id, {bool isDefault = false}) => AddressModel.fromJson({
      '_id': id, 'label': 'Home', 'recipientName': 'Test', 'phoneNumber': '+923001234567', 'addressLine1': 'House 1 Street 2',
      'city': 'Lahore', 'state': 'Punjab', 'zipCode': '54000', 'country': 'Pakistan', 'isDefault': isDefault,
    });

void main() {
  test('active zones use the server filter (status != inactive, not deleted)', () {
    final z = CheckoutDelivery.activeZones([_zone('a'), _zone('b', status: 'inactive'), _zone('c', deleted: true), _zone('d', status: 'draft')]);
    expect(z.map((e) => e.id), ['a', 'd']);
  });

  test('zone is sent without asking only when there is exactly one', () {
    expect(CheckoutDelivery.autoZone([]), isNull);
    expect(CheckoutDelivery.autoZone([_zone('a')])!.id, 'a');
    expect(CheckoutDelivery.autoZone([_zone('a'), _zone('b')]), isNull);
  });

  test('address: default first, else the first saved one', () {
    expect(CheckoutDelivery.pickAddress([]), isNull);
    expect(CheckoutDelivery.pickAddress([_addr('1'), _addr('2', isDefault: true)])!.id, '2');
    expect(CheckoutDelivery.pickAddress([_addr('1'), _addr('2')])!.id, '1');
  });

  test('checkout session reads the zone it was created with', () {
    final s = CheckoutSession.fromJson({'_id': 'c1', 'userId': 'u1', 'addressId': 'a1', 'shippingZoneId': 'z1', 'currency': 'PKR', 'items': []});
    expect((s.addressId, s.shippingZoneId), ('a1', 'z1'));
  });

  test('bank details are not requested without a checkout id', () async {
    expect(await ManualTransferRepository().getBankDetails(''), isNull);
  });
}
