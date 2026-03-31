class ShippingAddress {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      state,
      zipCode,
      country,
    ];
    return parts.join(', ');
  }
}
