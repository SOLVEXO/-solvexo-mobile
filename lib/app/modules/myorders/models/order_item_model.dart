class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? image;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'image': image,
    };
  }

  double get total => price * quantity;
}
