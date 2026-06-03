class ShippingOption {
  final String id;
  final String type;
  final String charges;
  final double amount;
  final String time;
  final String city;
  final String province;
  final String country;

  ShippingOption({
    required this.id,
    required this.type,
    required this.charges,
    required this.amount,
    required this.time,
    required this.city,
    required this.province,
    required this.country,
  });
}

class ShippingZoneModel {
  final String id;
  final String country;
  final String province;
  final String city;
  final double shippingPrice;
  final String estimatedDeliveryTime;
  final String status;
  final bool isDelete;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShippingZoneModel({
    required this.id,
    required this.country,
    required this.province,
    required this.city,
    required this.shippingPrice,
    required this.estimatedDeliveryTime,
    required this.status,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingZoneModel.fromJson(Map<String, dynamic> json) {
    return ShippingZoneModel(
      id: json['_id'] as String,
      country: json['country'] as String,
      province: json['province'] as String,
      city: json['city'] as String,
      shippingPrice: (json['shippingPrice'] as num).toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as String,
      status: json['status'] as String,
      isDelete: json['isDelete'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'country': country,
    'province': province,
    'city': city,
    'shippingPrice': shippingPrice,
    'estimatedDeliveryTime': estimatedDeliveryTime,
    'status': status,
    'isDelete': isDelete,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Convert API zone → ShippingOption for UI use
  ShippingOption toShippingOption() {
    return ShippingOption(
      id: id,
      type: "$city, $province",
      charges: "Rs. ${shippingPrice.toStringAsFixed(0)}",
      amount: shippingPrice,
      time: "Estimated delivery: $estimatedDeliveryTime",
      city: city,
      province: province,
      country: country,
    );
  }
}
