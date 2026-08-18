import 'package:book_store_app/app/data/models/bookings/bookable_service_model.dart';

class PackagePurchaseModel {
  final String id;
  final String packageId;
  final String serviceId;
  final String buyerId;
  final int sessionsTotal;
  final int sessionsRemaining;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final double amountPaid;
  final String currency;
  final String status; // 'active' | 'expired' | 'fully_used' | 'cancelled'
  final BookableServiceModel? service;

  const PackagePurchaseModel({
    required this.id,
    required this.packageId,
    required this.serviceId,
    required this.buyerId,
    required this.sessionsTotal,
    required this.sessionsRemaining,
    required this.purchasedAt,
    required this.expiresAt,
    required this.amountPaid,
    this.currency = 'USD',
    this.status = 'active',
    this.service,
  });

  bool get isUsable => status == 'active' && sessionsRemaining > 0 && expiresAt.isAfter(DateTime.now());

  factory PackagePurchaseModel.fromJson(Map<String, dynamic> json) {
    return PackagePurchaseModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      packageId: json['packageId'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      sessionsTotal: (json['sessionsTotal'] as num?)?.toInt() ?? 0,
      sessionsRemaining: (json['sessionsRemaining'] as num?)?.toInt() ?? 0,
      purchasedAt: DateTime.tryParse(json['purchasedAt'] as String? ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ?? DateTime.now(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'active',
      service: json['service'] != null ? BookableServiceModel.fromJson(json['service'] as Map<String, dynamic>) : null,
    );
  }
}
