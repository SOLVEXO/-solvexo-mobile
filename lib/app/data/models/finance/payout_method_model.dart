class PayoutMethodModel {
  final String id;
  final String type; // bank_transfer | paypal | stripe
  final bool isDefault;
  final String? bankName;
  final String? accountHolder;
  final String? accountLast4;
  final String? routingNumber;
  final String? externalAccountId;
  final String status; // active | inactive | pending_verification

  const PayoutMethodModel({
    required this.id,
    required this.type,
    required this.isDefault,
    this.bankName,
    this.accountHolder,
    this.accountLast4,
    this.routingNumber,
    this.externalAccountId,
    required this.status,
  });

  factory PayoutMethodModel.fromJson(Map<String, dynamic> json) => PayoutMethodModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'bank_transfer',
        isDefault: json['isDefault'] as bool? ?? false,
        bankName: json['bankName'] as String?,
        accountHolder: json['accountHolder'] as String?,
        accountLast4: json['accountLast4'] as String?,
        routingNumber: json['routingNumber'] as String?,
        externalAccountId: json['externalAccountId'] as String?,
        status: json['status'] as String? ?? 'active',
      );

  String get typeLabel {
    switch (type) {
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'bank_transfer':
      default:
        return 'Bank Transfer';
    }
  }

  String get displayLabel {
    if (type == 'bank_transfer') {
      final name = bankName?.isNotEmpty == true ? bankName : 'Bank Account';
      return accountLast4 != null ? '$name ••$accountLast4' : name!;
    }
    return externalAccountId?.isNotEmpty == true ? '$typeLabel — $externalAccountId' : typeLabel;
  }

  bool get isActive => status == 'active';
}
