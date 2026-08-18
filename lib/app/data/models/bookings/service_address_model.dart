class ServiceAddressModel {
  final String? addressLine1;
  final String? city;
  final String? phone;

  const ServiceAddressModel({this.addressLine1, this.city, this.phone});

  factory ServiceAddressModel.fromJson(Map<String, dynamic> json) {
    return ServiceAddressModel(
      addressLine1: json['addressLine1'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (addressLine1 != null) 'addressLine1': addressLine1,
    if (city != null) 'city': city,
    if (phone != null) 'phone': phone,
  };
}
