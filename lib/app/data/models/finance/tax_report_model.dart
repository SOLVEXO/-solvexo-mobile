class TaxReportModel {
  final String id;
  final String period; // q1 | q2 | q3 | q4 | annual
  final int year;
  final String currency;
  final DateTime fromDate;
  final DateTime toDate;
  final double totalRevenue;
  final double totalFees;
  final double totalRefunds;
  final double totalPayouts;
  final double netRevenue;
  final double estimatedTax;
  final int transactionCount;
  final String? pdfUrl;
  final DateTime? generatedAt;

  const TaxReportModel({
    required this.id,
    required this.period,
    required this.year,
    this.currency = 'USD',
    required this.fromDate,
    required this.toDate,
    required this.totalRevenue,
    required this.totalFees,
    required this.totalRefunds,
    required this.totalPayouts,
    required this.netRevenue,
    required this.estimatedTax,
    required this.transactionCount,
    this.pdfUrl,
    this.generatedAt,
  });

  factory TaxReportModel.fromJson(Map<String, dynamic> json) => TaxReportModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        period: json['period'] as String? ?? 'q1',
        year: json['year'] as int? ?? DateTime.now().year,
        currency: json['currency'] as String? ?? 'USD',
        fromDate: json['fromDate'] != null ? DateTime.tryParse(json['fromDate'] as String) ?? DateTime.now() : DateTime.now(),
        toDate: json['toDate'] != null ? DateTime.tryParse(json['toDate'] as String) ?? DateTime.now() : DateTime.now(),
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
        totalFees: (json['totalFees'] as num?)?.toDouble() ?? 0,
        totalRefunds: (json['totalRefunds'] as num?)?.toDouble() ?? 0,
        totalPayouts: (json['totalPayouts'] as num?)?.toDouble() ?? 0,
        netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0,
        estimatedTax: (json['estimatedTax'] as num?)?.toDouble() ?? 0,
        transactionCount: json['transactionCount'] as int? ?? 0,
        pdfUrl: json['pdfUrl'] as String?,
        generatedAt: json['generatedAt'] != null ? DateTime.tryParse(json['generatedAt'] as String) : null,
      );

  String amountLabel(double v) => currency == 'PKR' ? 'PKR ${v.toStringAsFixed(2)}' : '\$${v.toStringAsFixed(2)}';

  String get periodLabel {
    switch (period) {
      case 'q1':
        return 'Q1 $year';
      case 'q2':
        return 'Q2 $year';
      case 'q3':
        return 'Q3 $year';
      case 'q4':
        return 'Q4 $year';
      case 'annual':
        return 'Annual $year';
      default:
        return '$period $year';
    }
  }

  String get rangeLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[fromDate.month - 1]} – ${months[toDate.month - 1]}';
  }
}
