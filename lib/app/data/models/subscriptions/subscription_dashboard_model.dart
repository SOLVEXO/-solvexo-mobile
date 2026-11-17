class PlanBreakdownEntry {
  final String planId;
  final String planName;
  final int subscriberCount;
  final double mrrContributionUSD;

  const PlanBreakdownEntry({required this.planId, required this.planName, required this.subscriberCount, required this.mrrContributionUSD});

  factory PlanBreakdownEntry.fromJson(Map<String, dynamic> json) {
    return PlanBreakdownEntry(
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      subscriberCount: json['subscriberCount'] as int? ?? 0,
      mrrContributionUSD: (json['mrrContributionUSD'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SubscriptionInvoiceModel {
  final String id;
  final String invoiceNumber;
  final double amountUSD;
  final String status;
  final DateTime? paidAt;

  const SubscriptionInvoiceModel({required this.id, required this.invoiceNumber, required this.amountUSD, required this.status, this.paidAt});

  factory SubscriptionInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionInvoiceModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      invoiceNumber: json['invoiceNumber'] as String? ?? '',
      amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'] as String) : null,
    );
  }
}

class SubscriptionDashboardModel {
  final double mrr;
  final double arr;
  final int activeSubscribersCount;
  final double totalRevenue;
  final int newSubscribersThisMonth;
  final int canceledThisMonth;
  final double churnRate;
  final double revenueThisMonth;
  final double revenueLastMonth;
  final double revenueGrowthPercent;
  final List<PlanBreakdownEntry> planBreakdown;
  final List<SubscriptionInvoiceModel> recentInvoices;

  const SubscriptionDashboardModel({
    required this.mrr,
    required this.arr,
    required this.activeSubscribersCount,
    required this.totalRevenue,
    required this.newSubscribersThisMonth,
    required this.canceledThisMonth,
    required this.churnRate,
    required this.revenueThisMonth,
    required this.revenueLastMonth,
    required this.revenueGrowthPercent,
    required this.planBreakdown,
    required this.recentInvoices,
  });

  static const empty = SubscriptionDashboardModel(
    mrr: 0, arr: 0, activeSubscribersCount: 0, totalRevenue: 0,
    newSubscribersThisMonth: 0, canceledThisMonth: 0, churnRate: 0,
    revenueThisMonth: 0, revenueLastMonth: 0, revenueGrowthPercent: 0,
    planBreakdown: [], recentInvoices: [],
  );

  factory SubscriptionDashboardModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionDashboardModel(
      mrr: (json['mrr'] as num?)?.toDouble() ?? 0,
      arr: (json['arr'] as num?)?.toDouble() ?? 0,
      activeSubscribersCount: json['activeSubscribersCount'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      newSubscribersThisMonth: json['newSubscribersThisMonth'] as int? ?? 0,
      canceledThisMonth: json['canceledThisMonth'] as int? ?? 0,
      churnRate: (json['churnRate'] as num?)?.toDouble() ?? 0,
      revenueThisMonth: (json['revenueThisMonth'] as num?)?.toDouble() ?? 0,
      revenueLastMonth: (json['revenueLastMonth'] as num?)?.toDouble() ?? 0,
      revenueGrowthPercent: (json['revenueGrowthPercent'] as num?)?.toDouble() ?? 0,
      planBreakdown: (json['planBreakdown'] as List? ?? []).cast<Map<String, dynamic>>().map(PlanBreakdownEntry.fromJson).toList(),
      recentInvoices: (json['recentInvoices'] as List? ?? []).cast<Map<String, dynamic>>().map(SubscriptionInvoiceModel.fromJson).toList(),
    );
  }
}
