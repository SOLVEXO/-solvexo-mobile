enum FinanceTransactionType { sale, payout, fee, refund, adjustment }

FinanceTransactionType financeTransactionTypeFromString(String? value) {
  switch (value) {
    case 'sale':
      return FinanceTransactionType.sale;
    case 'payout':
      return FinanceTransactionType.payout;
    case 'fee':
      return FinanceTransactionType.fee;
    case 'refund':
      return FinanceTransactionType.refund;
    case 'adjustment':
      return FinanceTransactionType.adjustment;
    default:
      return FinanceTransactionType.adjustment;
  }
}

extension FinanceTransactionTypeX on FinanceTransactionType {
  String get apiValue {
    switch (this) {
      case FinanceTransactionType.sale:
        return 'sale';
      case FinanceTransactionType.payout:
        return 'payout';
      case FinanceTransactionType.fee:
        return 'fee';
      case FinanceTransactionType.refund:
        return 'refund';
      case FinanceTransactionType.adjustment:
        return 'adjustment';
    }
  }

  String get label {
    switch (this) {
      case FinanceTransactionType.sale:
        return 'Sale';
      case FinanceTransactionType.payout:
        return 'Payout';
      case FinanceTransactionType.fee:
        return 'Fee';
      case FinanceTransactionType.refund:
        return 'Refund';
      case FinanceTransactionType.adjustment:
        return 'Adjustment';
    }
  }
}

class FinanceTransactionModel {
  final String id;
  final FinanceTransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String currency;
  final String description;
  final String? referenceId;
  final String? referenceType;
  final String status;
  final DateTime createdAt;

  const FinanceTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.currency = 'USD',
    required this.description,
    this.referenceId,
    this.referenceType,
    required this.status,
    required this.createdAt,
  });

  bool get isCredit => amount >= 0;

  String _amountLabel(double v) => currency == 'PKR' ? 'PKR ${v.toStringAsFixed(2)}' : '\$${v.toStringAsFixed(2)}';

  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    return '$sign${_amountLabel(amount.abs())}';
  }

  String get formattedBalanceAfter => _amountLabel(balanceAfter);

  factory FinanceTransactionModel.fromJson(Map<String, dynamic> json) => FinanceTransactionModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        type: financeTransactionTypeFromString(json['type'] as String?),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0,
        balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'USD',
        description: json['description'] as String? ?? '',
        referenceId: json['referenceId'] as String?,
        referenceType: json['referenceType'] as String?,
        status: json['status'] as String? ?? 'completed',
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now() : DateTime.now(),
      );
}
