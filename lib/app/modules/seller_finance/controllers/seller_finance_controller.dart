import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TransactionType { sale, payout, fee, refund }

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.sale:    return 'Sale';
      case TransactionType.payout:  return 'Payout';
      case TransactionType.fee:     return 'Fee';
      case TransactionType.refund:  return 'Refund';
    }
  }

  Color get color {
    switch (this) {
      case TransactionType.sale:    return const Color(0xFF16A34A);
      case TransactionType.payout:  return const Color(0xFF2563EB);
      case TransactionType.fee:     return const Color(0xFFF59E0B);
      case TransactionType.refund:  return const Color(0xFFDC2626);
    }
  }

  Color get bgColor {
    switch (this) {
      case TransactionType.sale:    return const Color(0xFFDCFCE7);
      case TransactionType.payout:  return const Color(0xFFDBEAFE);
      case TransactionType.fee:     return const Color(0xFFFEF3C7);
      case TransactionType.refund:  return const Color(0xFFFEE2E2);
    }
  }

  bool get isPositive => this == TransactionType.sale;
  bool get isNegative => this == TransactionType.payout ||
      this == TransactionType.fee ||
      this == TransactionType.refund;
}

class FinanceTransaction {
  final String date;
  final String description;
  final TransactionType type;
  final double amount;
  final double balance;

  const FinanceTransaction({
    required this.date,
    required this.description,
    required this.type,
    required this.amount,
    required this.balance,
  });

  String get formattedAmount {
    final sign = type.isPositive ? '+' : '-';
    return '$sign\$${amount.abs().toStringAsFixed(2)}';
  }
}

class FeeItem {
  final String label;
  final String value;
  const FeeItem({required this.label, required this.value});
}

class TaxReport {
  final String title;
  final String period;
  const TaxReport({required this.title, required this.period});
}

class SellerFinanceController extends GetxController {
  final RxBool isLoading = false.obs;

  // Balance
  final RxDouble availableBalance = 3160.40.obs;
  final RxDouble pendingBalance = 840.00.obs;
  final RxString nextPayoutDate = 'Jul 7'.obs;
  final RxString paymentMethod = 'Bank ••4821'.obs;

  // Stats
  final RxDouble monthRevenue = 9100.0.obs;
  final RxDouble revenueChange = 23.0.obs;
  final RxDouble platformFees = 728.0.obs;
  final RxDouble totalPaidOut = 24800.0.obs;
  final RxDouble pendingTax = 1240.0.obs;

  // Filter
  final RxString activeFilter = 'All'.obs;
  final filters = const ['All', 'Sales', 'Payouts', 'Fees', 'Refunds'];

  // Transactions (static — replace with API call)
  final RxList<FinanceTransaction> transactions = <FinanceTransaction>[
    FinanceTransaction(
      date: 'May 20',
      description: 'Payout — Bank Transfer',
      type: TransactionType.payout,
      amount: 2840.00,
      balance: 320.40,
    ),
    FinanceTransaction(
      date: 'May 18',
      description: 'Sale — Grade 5 Math Bundle × 6',
      type: TransactionType.sale,
      amount: 294.00,
      balance: 3160.40,
    ),
    FinanceTransaction(
      date: 'May 17',
      description: 'Sale — Fractions Kit × 3',
      type: TransactionType.sale,
      amount: 54.00,
      balance: 2866.40,
    ),
    FinanceTransaction(
      date: 'May 17',
      description: 'Platform Fee (8%)',
      type: TransactionType.fee,
      amount: 27.84,
      balance: 2812.40,
    ),
    FinanceTransaction(
      date: 'May 16',
      description: 'Refund — Order #8815',
      type: TransactionType.refund,
      amount: 12.00,
      balance: 2840.24,
    ),
    FinanceTransaction(
      date: 'May 15',
      description: 'Sale — Ceramic Mug Set',
      type: TransactionType.sale,
      amount: 58.00,
      balance: 2852.24,
    ),
    FinanceTransaction(
      date: 'May 14',
      description: 'Sale — Science Kit Bundle × 2',
      type: TransactionType.sale,
      amount: 86.00,
      balance: 2794.24,
    ),
    FinanceTransaction(
      date: 'May 13',
      description: 'Platform Fee (8%)',
      type: TransactionType.fee,
      amount: 11.52,
      balance: 2708.24,
    ),
  ].obs;

  // Payout schedule
  final String payoutFrequency = 'Weekly (Every Monday)';
  final String payoutCurrency = 'USD';
  final String payoutMinimum = '\$50.00';

  // Fee breakdown
  final feeItems = const [
    FeeItem(label: 'Marketplace Listing', value: 'Free'),
    FeeItem(label: 'Transaction Fee', value: '8% per sale'),
    FeeItem(label: 'Payment Processing', value: '2.9% + \$0.30'),
    FeeItem(label: 'Digital Delivery', value: 'Included'),
    FeeItem(label: 'AI Credits', value: '750 / month'),
  ];

  // Tax reports
  final taxReports = const [
    TaxReport(title: 'Q1 2026 Summary', period: 'Jan – Mar'),
    TaxReport(title: 'Q4 2025 Summary', period: 'Oct – Dec'),
    TaxReport(title: 'Annual 2025', period: 'Full Year'),
  ];

  List<FinanceTransaction> get filteredTransactions {
    if (activeFilter.value == 'All') return transactions;
    final map = {
      'Sales': TransactionType.sale,
      'Payouts': TransactionType.payout,
      'Fees': TransactionType.fee,
      'Refunds': TransactionType.refund,
    };
    final t = map[activeFilter.value];
    if (t == null) return transactions;
    return transactions.where((tx) => tx.type == t).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1500));
    isLoading.value = false;
  }

  @override
  Future<void> refresh() async => _loadData();

  void setFilter(String f) => activeFilter.value = f;
}
