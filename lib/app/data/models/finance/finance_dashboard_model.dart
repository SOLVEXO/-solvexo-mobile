class FinanceNextPayoutMethod {
  final String type;
  final String? bankName;
  final String? last4;

  const FinanceNextPayoutMethod({required this.type, this.bankName, this.last4});

  factory FinanceNextPayoutMethod.fromJson(Map<String, dynamic> json) => FinanceNextPayoutMethod(
        type: json['type'] as String? ?? '',
        bankName: json['bankName'] as String?,
        last4: json['last4'] as String?,
      );

  String get label {
    if (bankName != null && bankName!.isNotEmpty) {
      return last4 != null ? '$bankName ••$last4' : bankName!;
    }
    switch (type) {
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'bank_transfer':
        return last4 != null ? 'Bank ••$last4' : 'Bank Transfer';
      default:
        return type;
    }
  }
}

class FinanceNextPayout {
  final double? pendingAmount;
  final DateTime? scheduledAt;
  final FinanceNextPayoutMethod? method;

  const FinanceNextPayout({this.pendingAmount, this.scheduledAt, this.method});

  factory FinanceNextPayout.fromJson(Map<String, dynamic> json) => FinanceNextPayout(
        pendingAmount: (json['pendingAmount'] as num?)?.toDouble(),
        scheduledAt: json['scheduledAt'] != null ? DateTime.tryParse(json['scheduledAt'] as String) : null,
        method: json['method'] != null ? FinanceNextPayoutMethod.fromJson(json['method'] as Map<String, dynamic>) : null,
      );
}

class FinanceSummary {
  final double thisMonthRevenue;
  final double revenueGrowthPercent;
  final double platformFees;
  final double totalPaidOut;
  final double pendingTax;

  const FinanceSummary({
    required this.thisMonthRevenue,
    required this.revenueGrowthPercent,
    required this.platformFees,
    required this.totalPaidOut,
    required this.pendingTax,
  });

  static const empty = FinanceSummary(
    thisMonthRevenue: 0, revenueGrowthPercent: 0, platformFees: 0, totalPaidOut: 0, pendingTax: 0,
  );

  factory FinanceSummary.fromJson(Map<String, dynamic> json) => FinanceSummary(
        thisMonthRevenue: (json['thisMonthRevenue'] as num?)?.toDouble() ?? 0,
        revenueGrowthPercent: (json['revenueGrowthPercent'] as num?)?.toDouble() ?? 0,
        platformFees: (json['platformFees'] as num?)?.toDouble() ?? 0,
        totalPaidOut: (json['totalPaidOut'] as num?)?.toDouble() ?? 0,
        pendingTax: (json['pendingTax'] as num?)?.toDouble() ?? 0,
      );
}

class FinanceDashboardScheduleSummary {
  final String frequency;
  final bool isEnabled;
  final double minimumAmount;
  final DateTime? nextPayoutAt;

  const FinanceDashboardScheduleSummary({
    required this.frequency,
    required this.isEnabled,
    required this.minimumAmount,
    this.nextPayoutAt,
  });

  static const empty = FinanceDashboardScheduleSummary(frequency: 'weekly', isEnabled: true, minimumAmount: 50);

  factory FinanceDashboardScheduleSummary.fromJson(Map<String, dynamic> json) => FinanceDashboardScheduleSummary(
        frequency: json['frequency'] as String? ?? 'weekly',
        isEnabled: json['isEnabled'] as bool? ?? true,
        minimumAmount: (json['minimumAmount'] as num?)?.toDouble() ?? 50,
        nextPayoutAt: json['nextPayoutAt'] != null ? DateTime.tryParse(json['nextPayoutAt'] as String) : null,
      );
}

class FinanceFeeBreakdown {
  final String marketplaceListingFee;
  final String transactionFee;
  final String paymentProcessing;
  final String digitalDelivery;
  final String aiCredits;

  const FinanceFeeBreakdown({
    required this.marketplaceListingFee,
    required this.transactionFee,
    required this.paymentProcessing,
    required this.digitalDelivery,
    required this.aiCredits,
  });

  static const empty = FinanceFeeBreakdown(
    marketplaceListingFee: '—', transactionFee: '—', paymentProcessing: '—', digitalDelivery: '—', aiCredits: '—',
  );

  factory FinanceFeeBreakdown.fromJson(Map<String, dynamic> json) => FinanceFeeBreakdown(
        marketplaceListingFee: json['marketplaceListingFee'] as String? ?? '—',
        transactionFee: json['transactionFee'] as String? ?? '—',
        paymentProcessing: json['paymentProcessing'] as String? ?? '—',
        digitalDelivery: json['digitalDelivery'] as String? ?? '—',
        aiCredits: json['aiCredits'] as String? ?? '—',
      );

  List<MapEntry<String, String>> get asEntries => [
        MapEntry('Marketplace Listing', marketplaceListingFee),
        MapEntry('Transaction Fee', transactionFee),
        MapEntry('Payment Processing', paymentProcessing),
        MapEntry('Digital Delivery', digitalDelivery),
        MapEntry('AI Credits', aiCredits),
      ];
}

/// One store can hold a separate balance/schedule per currency (e.g. a
/// Pakistani seller earning both USD-Stripe and PKR-manual-transfer sales) —
/// each currency the store has ever transacted in gets its own wallet here.
class FinanceWallet {
  final String currency;
  final double availableBalance;
  final double pendingBalance;
  final FinanceNextPayout nextPayout;
  final FinanceSummary summary;
  final FinanceDashboardScheduleSummary payoutSchedule;
  // Set when a refund/chargeback reversal drove the balance negative —
  // typically because funds were already withdrawn before the refund landed.
  // See FinanceService.recordRefund on the backend.
  final bool isFlaggedForReview;
  final String? flaggedReason;

  const FinanceWallet({
    required this.currency,
    required this.availableBalance,
    required this.pendingBalance,
    required this.nextPayout,
    required this.summary,
    required this.payoutSchedule,
    this.isFlaggedForReview = false,
    this.flaggedReason,
  });

  static const empty = FinanceWallet(
    currency: 'USD',
    availableBalance: 0,
    pendingBalance: 0,
    nextPayout: FinanceNextPayout(),
    summary: FinanceSummary.empty,
    payoutSchedule: FinanceDashboardScheduleSummary.empty,
  );

  factory FinanceWallet.fromJson(Map<String, dynamic> json) => FinanceWallet(
        currency: json['currency'] as String? ?? 'USD',
        availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0,
        pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0,
        nextPayout: json['nextPayout'] != null
            ? FinanceNextPayout.fromJson(json['nextPayout'] as Map<String, dynamic>)
            : const FinanceNextPayout(),
        summary: json['summary'] != null ? FinanceSummary.fromJson(json['summary'] as Map<String, dynamic>) : FinanceSummary.empty,
        payoutSchedule: json['payoutSchedule'] != null
            ? FinanceDashboardScheduleSummary.fromJson(json['payoutSchedule'] as Map<String, dynamic>)
            : FinanceDashboardScheduleSummary.empty,
        isFlaggedForReview: json['isFlaggedForReview'] as bool? ?? false,
        flaggedReason: json['flaggedReason'] as String?,
      );

  String amountLabel(double v) => currency == 'PKR' ? 'PKR ${v.toStringAsFixed(2)}' : '\$${v.toStringAsFixed(2)}';
}

class FinanceDashboardModel {
  final List<FinanceWallet> wallets;
  final FinanceFeeBreakdown feeBreakdown;

  const FinanceDashboardModel({required this.wallets, required this.feeBreakdown});

  static const empty = FinanceDashboardModel(wallets: [FinanceWallet.empty], feeBreakdown: FinanceFeeBreakdown.empty);

  factory FinanceDashboardModel.fromJson(Map<String, dynamic> json) {
    final wallets = (json['wallets'] as List?)?.cast<Map<String, dynamic>>().map(FinanceWallet.fromJson).toList() ?? const <FinanceWallet>[];
    return FinanceDashboardModel(
      wallets: wallets.isNotEmpty ? wallets : const [FinanceWallet.empty],
      feeBreakdown: json['feeBreakdown'] != null
          ? FinanceFeeBreakdown.fromJson(json['feeBreakdown'] as Map<String, dynamic>)
          : FinanceFeeBreakdown.empty,
    );
  }

  List<String> get currencies => wallets.map((w) => w.currency).toList();

  FinanceWallet walletFor(String currency) =>
      wallets.firstWhere((w) => w.currency == currency, orElse: () => wallets.isNotEmpty ? wallets.first : FinanceWallet.empty);
}
