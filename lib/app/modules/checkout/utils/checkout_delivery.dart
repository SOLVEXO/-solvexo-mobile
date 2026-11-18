import 'package:book_store_app/app/modules/address/models/address_model.dart';
import 'package:book_store_app/app/modules/checkout/models/shipping_options_model.dart';

/// What `POST /api/checkout/create-checkout` needs for physical items
/// (backend 5adba44, `checkout.service.ts:601-608, 674-680`):
/// - `addressId`: the chosen saved address (else the server uses the default)
/// - `shippingZoneId`: required once ANY active zone exists, otherwise
///   400 "Choose a delivery option for your address".
/// A zone is active when `status != 'inactive'` and it is not deleted
/// (same filter as `GET /api/checkout/getShippingZones`).
class CheckoutDelivery {
  CheckoutDelivery._();

  static List<ShippingZoneModel> activeZones(List<ShippingZoneModel> zones) =>
      zones.where((z) => !z.isDelete && z.status != 'inactive').toList();

  /// The default address, else the first saved one, else null.
  static AddressModel? pickAddress(List<AddressModel> addresses) {
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  /// The zone to send without asking: the only active one. Null when there
  /// are none (no zone needed) or more than one (the buyer chooses).
  static ShippingZoneModel? autoZone(List<ShippingZoneModel> active) => active.length == 1 ? active.first : null;
}
