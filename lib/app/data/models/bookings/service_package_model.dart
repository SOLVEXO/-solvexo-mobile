class ServicePackageModel {
  final String id;
  final String serviceId;
  final String name;
  final int sessionsCount;
  final double price;
  final String currency;
  final int validityDays;
  final String status; // 'active' | 'archived'

  const ServicePackageModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.sessionsCount,
    required this.price,
    this.currency = 'USD',
    required this.validityDays,
    this.status = 'active',
  });

  bool get isActive => status == 'active';

  factory ServicePackageModel.fromJson(Map<String, dynamic> json) {
    return ServicePackageModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sessionsCount: (json['sessionsCount'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      validityDays: (json['validityDays'] as num?)?.toInt() ?? 30,
      status: json['status'] as String? ?? 'active',
    );
  }
}
