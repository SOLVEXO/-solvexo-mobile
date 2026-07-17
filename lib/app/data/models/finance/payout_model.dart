class PayoutModel {
  final String id;
  final double amount;
  final String currency;
  final String status; // pending | processing | completed | failed
  final String? failureReason;
  final String? notes;
  final DateTime? processedAt;
  final DateTime createdAt;

  const PayoutModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    this.failureReason,
    this.notes,
    this.processedAt,
    required this.createdAt,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) => PayoutModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'USD',
        status: json['status'] as String? ?? 'processing',
        failureReason: json['failureReason'] as String?,
        notes: json['notes'] as String?,
        processedAt: json['processedAt'] != null ? DateTime.tryParse(json['processedAt'] as String) : null,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now() : DateTime.now(),
      );
}
