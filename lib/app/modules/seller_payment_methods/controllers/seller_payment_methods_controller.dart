import 'package:get/get.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String emoji;
  bool isEnabled;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    this.isEnabled = false,
  });
}

class SellerPaymentMethodsController extends GetxController {
  final RxList<PaymentMethod> methods = <PaymentMethod>[
    PaymentMethod(id: 'card', name: 'Credit / Debit Card', description: 'Visa, Mastercard, Amex', emoji: '💳', isEnabled: true),
    PaymentMethod(id: 'cash', name: 'Cash on Delivery', description: 'Collect payment at delivery', emoji: '💵', isEnabled: true),
    PaymentMethod(id: 'paypal', name: 'PayPal', description: 'Fast online payments', emoji: '🅿️', isEnabled: true),
    PaymentMethod(id: 'bank', name: 'Bank Transfer', description: 'Direct bank deposits', emoji: '🏦', isEnabled: false),
    PaymentMethod(id: 'apple', name: 'Apple Pay', description: 'Touch / Face ID checkout', emoji: '🍎', isEnabled: false),
    PaymentMethod(id: 'google', name: 'Google Pay', description: 'One-tap secure payments', emoji: '🔵', isEnabled: false),
  ].obs;

  void toggle(String id) {
    final i = methods.indexWhere((m) => m.id == id);
    if (i != -1) {
      methods[i].isEnabled = !methods[i].isEnabled;
      methods.refresh();
    }
  }

  String get summaryText {
    final enabled = methods.where((m) => m.isEnabled).map((m) => m.name.split(' ').first).join(', ');
    return enabled.isEmpty ? 'None' : enabled;
  }
}
