class AddressModel {
  String label;
  String name;
  String phone;
  String address;
  String apartment;
  String state;
  String city;
  String zip;
  bool isDefault;

  AddressModel({
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
    required this.apartment,
    required this.state,
    required this.city,
    required this.zip,
    this.isDefault = false,
  });
}
