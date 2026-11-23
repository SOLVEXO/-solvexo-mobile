// Finance (docs Part B 2.1, 6.10). Shapes from the live API, test store,
// 2026-11-17. Every amount is the server's; nothing is calculated here.

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
DateTime? _t(dynamic v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();
Map<String, dynamic> _m(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : const {};

/// `GET /api/finance/:storeId/earnings-summary`.
class EarningsSummary {
  const EarningsSummary({
    required this.currency,
    required this.available,
    required this.clearing,
    required this.clearingReleaseAt,
    required this.expected,
    required this.commissionOwed,
    required this.isFlaggedForReview,
    required this.nextPayoutDate,
    required this.payoutFrequency,
    required this.platformFees,
    required this.cardProcessingPercent,
    required this.cardProcessingFixedUSD,
    required this.clearingDaysCard,
    required this.clearingDaysOther,
  });

  final String currency;
  final double available;
  final double clearing;
  final DateTime? clearingReleaseAt;
  final ExpectedEarnings expected;

  /// Platform fee the seller owes on seller-collected COD (docs 2.3); nets
  /// off later sales.
  final double commissionOwed;
  final bool isFlaggedForReview;
  final DateTime? nextPayoutDate;
  final String? payoutFrequency;

  /// {'digital': {mode, value}, 'physical': {mode, value}}.
  final Map<String, PlatformFeeRule> platformFees;
  final double? cardProcessingPercent;
  final double? cardProcessingFixedUSD;
  final int? clearingDaysCard;
  final int? clearingDaysOther;

  factory EarningsSummary.fromJson(Map<String, dynamic> j) {
    final fees = _m(j['platformFees']);
    final card = _m(j['cardProcessing']);
    final days = _m(j['clearingDays']);
    return EarningsSummary(
      currency: j['currency']?.toString() ?? '',
      available: _d(j['available']),
      clearing: _d(j['clearing']),
      clearingReleaseAt: _t(j['clearingReleaseAt']),
      expected: ExpectedEarnings.fromJson(_m(j['expected'])),
      commissionOwed: _d(j['commissionOwed']),
      isFlaggedForReview: j['isFlaggedForReview'] == true,
      nextPayoutDate: _t(j['nextPayoutDate']),
      payoutFrequency: j['payoutFrequency']?.toString(),
      platformFees: {
        for (final e in fees.entries)
          if (e.value is Map) e.key: PlatformFeeRule.fromJson(_m(e.value)),
      },
      cardProcessingPercent: card['percent'] is num ? (card['percent'] as num).toDouble() : null,
      cardProcessingFixedUSD: card['fixedUSD'] is num ? (card['fixedUSD'] as num).toDouble() : null,
      clearingDaysCard: days['card'] is num ? (days['card'] as num).toInt() : null,
      clearingDaysOther: days['other'] is num ? (days['other'] as num).toInt() : null,
    );
  }
}

/// `expected`: money from open orders that is not earned yet.
class ExpectedEarnings {
  const ExpectedEarnings({
    required this.amount,
    required this.feeEstimate,
    required this.orders,
    required this.toShip,
    required this.openOrders,
    required this.capped,
  });

  final double amount;
  final double feeEstimate;
  final int orders;
  final int toShip;
  final int openOrders;
  final bool capped;

  factory ExpectedEarnings.fromJson(Map<String, dynamic> j) => ExpectedEarnings(
        amount: _d(j['amount']),
        feeEstimate: _d(j['feeEstimate']),
        orders: _i(j['orders']),
        toShip: _i(j['toShip']),
        openOrders: _i(j['openOrders']),
        capped: j['capped'] == true,
      );
}

class PlatformFeeRule {
  const PlatformFeeRule({required this.mode, required this.value});
  final String mode; // percentage | fixed (USD per unit)
  final double value;

  factory PlatformFeeRule.fromJson(Map<String, dynamic> j) =>
      PlatformFeeRule(mode: j['mode']?.toString() ?? '', value: _d(j['value']));

  /// Wording only, from the server's own config.
  String get label => mode == 'percentage'
      ? '${value % 1 == 0 ? value.toInt() : value}% of the item price'
      : '\$${value.toStringAsFixed(2)} per unit';
}

/// `GET /api/finance/:storeId/earnings-statement?month=YYYY-MM`.
class EarningsStatement {
  const EarningsStatement({
    required this.month,
    required this.currency,
    required this.orderCount,
    required this.gross,
    required this.platformFee,
    required this.processingFee,
    required this.refunds,
    required this.net,
    required this.rows,
    required this.truncated,
  });

  final String month;
  final String currency;
  final int orderCount;
  final double gross;
  final double platformFee;
  final double processingFee;
  final double refunds;
  final double net;
  final List<StatementRow> rows;
  final bool truncated;

  factory EarningsStatement.fromJson(Map<String, dynamic> j) {
    final t = _m(j['totals']);
    return EarningsStatement(
      month: j['month']?.toString() ?? '',
      currency: j['currency']?.toString() ?? '',
      orderCount: _i(t['orderCount']),
      gross: _d(t['gross']),
      platformFee: _d(t['platformFee']),
      processingFee: _d(t['processingFee']),
      refunds: _d(t['refunds']),
      net: _d(t['net']),
      rows: (j['rows'] is List ? j['rows'] as List : const [])
          .whereType<Map>()
          .map((r) => StatementRow.fromJson(Map<String, dynamic>.from(r)))
          .toList(),
      truncated: j['truncated'] == true,
    );
  }
}

/// One statement line. The test store had no rows, so these keys follow the
/// CSV download's columns (Date, Order, Type, Gross, Platform fee,
/// Processing fee, Refund, Net, Status) and are read defensively.
class StatementRow {
  const StatementRow({
    this.date,
    required this.orderNumber,
    required this.type,
    required this.gross,
    required this.platformFee,
    required this.net,
    required this.status,
  });

  final DateTime? date;
  final String orderNumber;
  final String type;
  final double gross;
  final double platformFee;
  final double net;
  final String status;

  factory StatementRow.fromJson(Map<String, dynamic> j) => StatementRow(
        date: _t(j['date'] ?? j['createdAt']),
        orderNumber: (j['orderNumber'] ?? j['order'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        gross: _d(j['gross']),
        platformFee: _d(j['platformFee']),
        net: _d(j['net']),
        status: (j['status'] ?? '').toString(),
      );
}

/// `GET /api/finance/:storeId/fee-estimate?price&type[&premiumPercent]`
/// -> {currency, type, price, generatedAt, fee, net, reason, premium?}.
/// `premium` is only sent when `premiumPercent` (or `productId`) was asked
/// (backend fix #5); it is null when no member price applies.
class FeeEstimate {
  const FeeEstimate({
    required this.currency,
    required this.type,
    required this.price,
    required this.fee,
    required this.net,
    this.reason,
    this.premium,
    this.premiumAsked = false,
  });

  final String currency;
  final String type;
  final double price;
  final double fee;
  final double net;
  final String? reason;

  /// Earnings at the member price, from the server; null = not asked, or
  /// asked and no member price applies (see [premiumAsked]).
  final PremiumEstimate? premium;

  /// The response carried a `premium` key (the server was asked for it).
  final bool premiumAsked;

  factory FeeEstimate.fromJson(Map<String, dynamic> j) => FeeEstimate(
        currency: j['currency']?.toString() ?? '',
        type: j['type']?.toString() ?? '',
        price: _d(j['price']),
        fee: _d(j['fee']),
        net: _d(j['net']),
        reason: j['reason']?.toString(),
        premiumAsked: j.containsKey('premium'),
        premium: j['premium'] is Map ? PremiumEstimate.fromJson(Map<String, dynamic>.from(j['premium'] as Map)) : null,
      );
}

/// The `premium` block of the fee estimate: what a Premium member pays and
/// what the seller is credited, using the same rule as a real member sale.
class PremiumEstimate {
  const PremiumEstimate({
    required this.memberPrice,
    required this.sellerPercent,
    required this.platformPercent,
    required this.memberDiscountPercent,
    required this.platformFunded,
    required this.saleValue,
    required this.feePercent,
    required this.fee,
    required this.net,
  });

  final double memberPrice, sellerPercent, platformPercent, memberDiscountPercent;

  /// Part of the member discount Edudeen pays (credited to the seller).
  final double platformFunded;

  /// What the seller is credited before the fee: member price + platformFunded.
  final double saleValue;
  final double feePercent, fee, net;

  factory PremiumEstimate.fromJson(Map<String, dynamic> j) => PremiumEstimate(
        memberPrice: _d(j['memberPrice']),
        sellerPercent: _d(j['sellerPercent']),
        platformPercent: _d(j['platformPercent']),
        memberDiscountPercent: _d(j['memberDiscountPercent']),
        platformFunded: _d(j['platformFunded']),
        saleValue: _d(j['saleValue']),
        feePercent: _d(j['feePercent']),
        fee: _d(j['fee']),
        net: _d(j['net']),
      );
}
