class PayoutMethodModel {
  final String id;
  final String type; // bank_transfer | jazzcash | easypaisa | paypal | stripe
  final String currency; // USD | PKR
  final bool isDefault;
  final String? bankName;
  final String? accountHolder;
  final String? accountLast4;
  final String? routingNumber;
  final String? externalAccountId;
  final String status; // active | inactive | pending_verification
  final bool accountTitleMismatchFlagged;
  final String? accountTitleMismatchNote;

  const PayoutMethodModel({
    required this.id,
    required this.type,
    this.currency = 'USD',
    required this.isDefault,
    this.bankName,
    this.accountHolder,
    this.accountLast4,
    this.routingNumber,
    this.externalAccountId,
    required this.status,
    this.accountTitleMismatchFlagged = false,
    this.accountTitleMismatchNote,
  });

  factory PayoutMethodModel.fromJson(Map<String, dynamic> json) => PayoutMethodModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'bank_transfer',
        currency: json['currency'] as String? ?? 'USD',
        isDefault: json['isDefault'] as bool? ?? false,
        bankName: json['bankName'] as String?,
        accountHolder: json['accountHolder'] as String?,
        accountLast4: json['accountLast4'] as String?,
        routingNumber: json['routingNumber'] as String?,
        externalAccountId: json['externalAccountId'] as String?,
        status: json['status'] as String? ?? 'active',
        accountTitleMismatchFlagged: json['accountTitleMismatchFlagged'] as bool? ?? false,
        accountTitleMismatchNote: json['accountTitleMismatchNote'] as String?,
      );

  String get typeLabel {
    switch (type) {
      case 'jazzcash':
        return 'JazzCash';
      case 'easypaisa':
        return 'EasyPaisa';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'bank_transfer':
      default:
        return 'Bank Transfer';
    }
  }

  bool get isMobileWallet => type == 'jazzcash' || type == 'easypaisa';

  String get displayLabel {
    if (type == 'bank_transfer') {
      final name = bankName?.isNotEmpty == true ? bankName : 'Bank Account';
      return accountLast4 != null ? '$name ••$accountLast4' : name!;
    }
    if (isMobileWallet) {
      return externalAccountId?.isNotEmpty == true ? '$typeLabel — $externalAccountId' : typeLabel;
    }
    return externalAccountId?.isNotEmpty == true ? '$typeLabel — $externalAccountId' : typeLabel;
  }

  bool get isActive => status == 'active';
  bool get isPendingVerification => status == 'pending_verification';
}
