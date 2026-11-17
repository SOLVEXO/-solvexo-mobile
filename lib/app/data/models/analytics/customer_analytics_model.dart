class CustomerActivityPointModel {
  final DateTime date;
  final int newCustomers;
  final int returningCustomers;

  const CustomerActivityPointModel({required this.date, required this.newCustomers, required this.returningCustomers});

  factory CustomerActivityPointModel.fromJson(Map<String, dynamic> json) {
    return CustomerActivityPointModel(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      newCustomers: json['newCustomers'] as int? ?? 0,
      returningCustomers: json['returningCustomers'] as int? ?? 0,
    );
  }
}

class TopCustomerModel {
  final String userId;
  final String name;
  final String email;
  final int totalOrders;
  final double lifetimeValue;

  const TopCustomerModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.totalOrders,
    required this.lifetimeValue,
  });

  factory TopCustomerModel.fromJson(Map<String, dynamic> json) {
    return TopCustomerModel(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      lifetimeValue: (json['lifetimeValue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class GeoBreakdownModel {
  final String state;
  final int orders;
  final double revenue;

  const GeoBreakdownModel({required this.state, required this.orders, required this.revenue});

  factory GeoBreakdownModel.fromJson(Map<String, dynamic> json) {
    return GeoBreakdownModel(
      state: json['state'] as String? ?? 'Unknown',
      orders: json['orders'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CustomerAnalyticsModel {
  final List<CustomerActivityPointModel> newVsReturning;
  final double averageLifetimeValue;
  final List<TopCustomerModel> topCustomersByLtv;
  final List<GeoBreakdownModel> geographicBreakdown;

  const CustomerAnalyticsModel({
    required this.newVsReturning,
    required this.averageLifetimeValue,
    required this.topCustomersByLtv,
    required this.geographicBreakdown,
  });

  static const empty = CustomerAnalyticsModel(
    newVsReturning: [], averageLifetimeValue: 0, topCustomersByLtv: [], geographicBreakdown: [],
  );

  factory CustomerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CustomerAnalyticsModel(
      newVsReturning: (json['newVsReturning'] as List? ?? []).cast<Map<String, dynamic>>().map(CustomerActivityPointModel.fromJson).toList(),
      averageLifetimeValue: (json['averageLifetimeValue'] as num?)?.toDouble() ?? 0,
      topCustomersByLtv: (json['topCustomersByLtv'] as List? ?? []).cast<Map<String, dynamic>>().map(TopCustomerModel.fromJson).toList(),
      geographicBreakdown: (json['geographicBreakdown'] as List? ?? []).cast<Map<String, dynamic>>().map(GeoBreakdownModel.fromJson).toList(),
    );
  }
}
