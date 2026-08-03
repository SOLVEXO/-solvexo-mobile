import 'package:book_store_app/app/modules/category/models/product_model.dart';

class CheckoutItem {
  final String? id;
  final String name;
  final String? sellerName;
  final bool sellerVerified;
  final List<VariantOption> options;
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
    this.sellerName,
    this.sellerVerified = false,
    this.options = const [],
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
      sellerName: json['sellerName'] as String?,
      sellerVerified: json['sellerVerified'] == true,
      options: (json['options'] as List? ?? [])
          .map((o) => VariantOption.fromJson(o as Map<String, dynamic>))
          .toList(),
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
    "options": options.map((o) => o.toJson()).toList(),
    "image": image,
    "price": price,
    "quantity": quantity,
    "productType": productType,
    "originalPrice": originalPrice,
  };
}
