class AddressModel {
  String? id;
  String label;
  String fullName;
  String phone;
  String addressLine1;
  String? addressLine2;
  String city;
  String state;
  String zipCode;
  String country;

  bool isDefault;

  AddressModel({
    this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'],
      label: json['label'] ?? 'Home',
      fullName: json['fullName'],
      phone: json['phone'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "label": label,
      "fullName": fullName,
      "phone": phone,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "city": city,
      "state": state,
      "zipCode": zipCode,
      "country": country,
    };
  }
}
