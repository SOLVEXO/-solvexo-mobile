class CheckoutItem {
  final String? id;
  final String name;
  final String? color;
  final String image;
  final double price;
  final int quantity;

  CheckoutItem({
    this.id,
    required this.name,
    this.color,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      image: json['image'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color": color,
    "image": image,
    "price": price,
    "quantity": quantity,
  };
}
