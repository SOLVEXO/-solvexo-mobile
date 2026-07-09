import 'package:book_store_app/app/data/models/subscriptions/subscription_dashboard_model.dart';

class SubscriberModel {
  final String id;
  final String planId;
  final String planName;
  final String customerName;
  final String customerEmail;
  final String billingInterval; // 'monthly' | 'yearly'
  final double amountUSD;
  final String status; // 'active' | 'paused' | 'canceled' | 'past_due'
  final DateTime? startedAt;
  final DateTime? currentPeriodEnd;
  final DateTime? nextBillingDate;
  final DateTime? canceledAt;
  final double totalPaidUSD;
  final List<SubscriptionInvoiceModel> invoices;

  const SubscriberModel({
    required this.id,
    required this.planId,
    required this.planName,
    required this.customerName,
    required this.customerEmail,
    required this.billingInterval,
    required this.amountUSD,
    required this.status,
    this.startedAt,
    this.currentPeriodEnd,
    this.nextBillingDate,
    this.canceledAt,
    this.totalPaidUSD = 0,
    this.invoices = const [],
  });

  factory SubscriberModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final plan = json['plan'] as Map<String, dynamic>?;
    return SubscriberModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? plan?['name'] as String? ?? 'Plan',
      customerName: customer?['name'] as String? ?? 'Unknown',
      customerEmail: customer?['email'] as String? ?? '',
      billingInterval: json['billingInterval'] as String? ?? 'monthly',
      amountUSD: (json['amountUSD'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'active',
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'] as String) : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null ? DateTime.tryParse(json['currentPeriodEnd'] as String) : null,
      nextBillingDate: json['nextBillingDate'] != null ? DateTime.tryParse(json['nextBillingDate'] as String) : null,
      canceledAt: json['canceledAt'] != null ? DateTime.tryParse(json['canceledAt'] as String) : null,
      totalPaidUSD: (json['totalPaidUSD'] as num?)?.toDouble() ?? 0,
      invoices: (json['invoices'] as List? ?? []).cast<Map<String, dynamic>>().map(SubscriptionInvoiceModel.fromJson).toList(),
    );
  }
}
