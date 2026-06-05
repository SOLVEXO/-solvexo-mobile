import 'package:get/get.dart';

class ShippingZone {
  final String id;
  final String name;
  final String countries;
  final String rate;
  final String deliveryTime;

  const ShippingZone({
    required this.id,
    required this.name,
    required this.countries,
    required this.rate,
    required this.deliveryTime,
  });
}

class SellerShippingController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxList<ShippingZone> zones = <ShippingZone>[
    const ShippingZone(id: 'z1', name: 'Domestic', countries: 'United States', rate: 'Free', deliveryTime: '3–5 business days'),
    const ShippingZone(id: 'z2', name: 'Canada', countries: 'Canada', rate: '\$12.00 flat rate', deliveryTime: '5–10 business days'),
    const ShippingZone(id: 'z3', name: 'International', countries: 'UK, Australia, EU', rate: '\$25.00 flat rate', deliveryTime: '10–21 business days'),
  ].obs;

  void deleteZone(String id) {
    zones.removeWhere((z) => z.id == id);
  }
}
