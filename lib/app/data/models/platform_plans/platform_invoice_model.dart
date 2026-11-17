/// Mirrors `solvexo-api`'s `PlatformPlanInvoice` schema
/// (`src/platform-plans/schemas/platform-plan-invoice.schema.ts`) — one
/// billing record for a store's platform-plan charge, returned by
/// `GET /api/platform-plans/:storeId/invoices`.
class PlatformInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String type; // initial | recurring | proration
  final double amountUSD;
  final String status; // paid | failed | pending | refunded | partially_refunded
  final DateTime? paidAt;
  final DateTime? refundedAt;
  final double refundedAmountUSD;
  final String? hostedInvoiceUrl;
  final String? invoicePdfUrl;
  final String? paymentMethodType;
  final DateTime? createdAt;

  const PlatformInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.type = 'recurring',
    this.amountUSD = 0,
    this.status = 'pending',
    this.paidAt,
    this.refundedAt,
    this.refundedAmountUSD = 0,
    this.hostedInvoiceUrl,
    this.invoicePdfUrl,
    this.paymentMethodType,
    this.createdAt,
  });

  factory PlatformInvoiceModel.fromJson(Map<String, dynamic> json) =>
      PlatformInvoiceModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        type: json['type'] as String? ?? 'recurring',
        amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
        status: json['status'] as String? ?? 'pending',
        paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'].toString()) : null,
        refundedAt: json['refundedAt'] != null ? DateTime.tryParse(json['refundedAt'].toString()) : null,
        refundedAmountUSD: (json['refundedAmountUSD'] as num?)?.toDouble() ?? 0,
        hostedInvoiceUrl: json['hostedInvoiceUrl'] as String?,
        invoicePdfUrl: json['invoicePdfUrl'] as String?,
        paymentMethodType: json['paymentMethodType'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      );
}
