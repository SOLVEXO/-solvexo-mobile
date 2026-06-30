class CheckoutItem {
  final String? id;
  final String name;
  final String? color;
  final String image;
  final double price;
  final int quantity;
  final String productType; // 'physical' or 'digital'

  CheckoutItem({
    this.id,
    required this.name,
    this.color,
    required this.image,
    required this.price,
    required this.quantity,
    this.productType = 'physical',
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      image: json['image'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      productType: json['productType'] as String? ?? 'physical',
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
  };
}
