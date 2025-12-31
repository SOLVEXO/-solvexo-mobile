enum PaymentType { gpay, applePay, card }

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String title;
  final String? last4;
  final String? brand;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.title,
    this.last4,
    this.brand,
    this.isDefault = false,
  });
}
