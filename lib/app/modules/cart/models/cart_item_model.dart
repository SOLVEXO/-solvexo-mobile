import 'package:book_store_app/app/modules/category/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  int selectedVariant;
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedVariant = 0,
    this.isSelected = false,
  });
}
