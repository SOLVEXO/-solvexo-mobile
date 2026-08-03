/// Company bank account details (+ live USD→PKR rate) shown to the buyer
/// before they transfer money and upload proof — see
/// `ManualTransferRepository.getBankDetails`.
class ManualPaymentBankDetails {
  final String? bankName;
  final String? accountTitle;
  final String? accountNumber;
  final String? iban;
  final String? jazzcashNumber;
  final String? easypaisaNumber;
  final String? instructions;
  final double usdToPkrRate;

  const ManualPaymentBankDetails({
    this.bankName,
    this.accountTitle,
    this.accountNumber,
    this.iban,
    this.jazzcashNumber,
    this.easypaisaNumber,
    this.instructions,
    required this.usdToPkrRate,
  });

  static const empty = ManualPaymentBankDetails(usdToPkrRate: 278);

  factory ManualPaymentBankDetails.fromJson(Map<String, dynamic> json) => ManualPaymentBankDetails(
        bankName: json['bankName'] as String?,
        accountTitle: json['accountTitle'] as String?,
        accountNumber: json['accountNumber'] as String?,
        iban: json['iban'] as String?,
        jazzcashNumber: json['jazzcashNumber'] as String?,
        easypaisaNumber: json['easypaisaNumber'] as String?,
        instructions: json['instructions'] as String?,
        usdToPkrRate: (json['usdToPkrRate'] as num?)?.toDouble() ?? 278,
      );

  /// Only the account fields the admin has actually filled in — drives which
  /// rows the "how to pay" screen renders.
  List<MapEntry<String, String>> get filledFields => [
        if (bankName != null && bankName!.isNotEmpty) MapEntry('Bank', bankName!),
        if (accountTitle != null && accountTitle!.isNotEmpty) MapEntry('Account Title', accountTitle!),
        if (accountNumber != null && accountNumber!.isNotEmpty) MapEntry('Account Number', accountNumber!),
        if (iban != null && iban!.isNotEmpty) MapEntry('IBAN', iban!),
        if (jazzcashNumber != null && jazzcashNumber!.isNotEmpty) MapEntry('JazzCash', jazzcashNumber!),
        if (easypaisaNumber != null && easypaisaNumber!.isNotEmpty) MapEntry('EasyPaisa', easypaisaNumber!),
      ];
}

/// A submitted (or re-submitted) manual bank-transfer payment proof and its
/// review status — see `ManualTransferRepository.submitPayment`/`getProofStatus`.
class ManualPaymentProof {
  final String id;
  final String checkoutId;
  final List<String> orderIds;
  final double amountUSD;
  final double amountPKR;
  final double fxRateUsed;
  final String? proofImageUrl;
  final String? transactionReference;
  final String? senderName;
  final String status; // pending | approved | rejected
  final String? rejectionReason;
  final int reuploadCount;
  final DateTime createdAt;

  const ManualPaymentProof({
    required this.id,
    required this.checkoutId,
    required this.orderIds,
    required this.amountUSD,
    required this.amountPKR,
    required this.fxRateUsed,
    this.proofImageUrl,
    this.transactionReference,
    this.senderName,
    required this.status,
    this.rejectionReason,
    this.reuploadCount = 0,
    required this.createdAt,
  });

  factory ManualPaymentProof.fromJson(Map<String, dynamic> json) => ManualPaymentProof(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        checkoutId: json['checkoutId'] as String? ?? '',
        orderIds: (json['orderIds'] as List? ?? []).map((e) => e.toString()).toList(),
        amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
        amountPKR: (json['amountPKR'] as num?)?.toDouble() ?? 0,
        fxRateUsed: (json['fxRateUsed'] as num?)?.toDouble() ?? 0,
        proofImageUrl: json['proofImageUrl'] as String?,
        transactionReference: json['transactionReference'] as String?,
        senderName: json['senderName'] as String?,
        status: json['status'] as String? ?? 'pending',
        rejectionReason: json['rejectionReason'] as String?,
        reuploadCount: json['reuploadCount'] as int? ?? 0,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
