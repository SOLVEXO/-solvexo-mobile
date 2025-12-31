import 'package:book_store_app/app/modules/category/models/customer_reviews.dart';
import 'package:book_store_app/app/modules/category/models/product_variant.dart';

class ProductModel {
  final String category;
  final String name;
  final String description;
  final String image;
  final double price;
  final double rating;
  final int reviews;
  final List<ProductVariant> variants;
  final List<ReviewModel> customerReviews;

  ProductModel({
    required this.variants,
    required this.customerReviews,
    required this.category,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviews,
  });

  // From JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      variants: json["variants"],
      customerReviews: json["customerReviews"],
      category: json["category"] ?? "",
      name: json["name"] ?? "",
      description: json["product discription"] ?? "",
      image: json["image"] ?? "",
      price: double.tryParse(json["price"].toString()) ?? 0.0,
      rating: double.tryParse(json["rating"].toString()) ?? 0.0,
      reviews: int.tryParse(json["reviews"].toString()) ?? 0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "variants": variants,
      "customerReviews": customerReviews,
      "name": name,
      "product discription": description,
      "image": image,
      "price": price,
      "rating": rating,
      "reviews": reviews,
    };
  }
}
