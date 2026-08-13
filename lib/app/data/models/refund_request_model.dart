/// Item-level refund request — `api/refund-request` (supersedes the old
/// free-text `orders/return-request` flow). One request always scopes to a
/// single seller's items within one order (`sellerOrderId`), never the whole
/// order.
class RefundRequestModel {
  final String id;
  final String orderId;
  final String sellerOrderId;
  final String storeId;
  final List<String> itemIds;
  final String requestedBy;
  final String requestedByRole;
  final String reason;
  final String status; // 'pending' | 'approved' | 'rejected'
  final double? buyerRefundAmount;
  final String? buyerRefundCurrency;
  final double? sellerDebitAmount;
  final String? sellerDebitCurrency;
  final String? stripeRefundId;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RefundRequestModel({
    required this.id,
    required this.orderId,
    required this.sellerOrderId,
    required this.storeId,
    required this.itemIds,
    required this.requestedBy,
    required this.requestedByRole,
    required this.reason,
    required this.status,
    this.buyerRefundAmount,
    this.buyerRefundCurrency,
    this.sellerDebitAmount,
    this.sellerDebitCurrency,
    this.stripeRefundId,
    this.reviewedBy,
    this.reviewedAt,
    this.resolutionNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory RefundRequestModel.fromJson(Map<String, dynamic> json) {
    return RefundRequestModel(
      id: json['_id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      sellerOrderId: json['sellerOrderId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      itemIds: (json['itemIds'] as List? ?? []).map((e) => e.toString()).toList(),
      requestedBy: json['requestedBy'] as String? ?? '',
      requestedByRole: json['requestedByRole'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      buyerRefundAmount: (json['buyerRefundAmount'] as num?)?.toDouble(),
      buyerRefundCurrency: json['buyerRefundCurrency'] as String?,
      sellerDebitAmount: (json['sellerDebitAmount'] as num?)?.toDouble(),
      sellerDebitCurrency: json['sellerDebitCurrency'] as String?,
      stripeRefundId: json['stripeRefundId'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'] as String)
          : null,
      resolutionNotes: json['resolutionNotes'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
