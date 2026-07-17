class CheckoutItem {
  final String? id;
  final String name;
  final String? color;
  final String image;
  final double price;
  final int quantity;
  final String productType; // 'physical' or 'digital'

  /// Non-null only when a subscriber (member) discount was applied
  /// server-side — `price` already reflects the discounted amount, this is
  /// the pre-discount unit price kept for strikethrough display.
  final double? originalPrice;

  CheckoutItem({
    this.id,
    required this.name,
    this.color,
    required this.image,
    required this.price,
    required this.quantity,
    this.productType = 'physical',
    this.originalPrice,
  });

  bool get hasMemberDiscount => originalPrice != null && originalPrice! > price;

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      image: json['image'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      productType: json['productType'] as String? ?? 'physical',
      originalPrice: json['originalPrice'] != null ? double.parse(json['originalPrice'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color": color,
    "image": image,
    "price": price,
    "quantity": quantity,
    "productType": productType,
    "originalPrice": originalPrice,
  };
}
