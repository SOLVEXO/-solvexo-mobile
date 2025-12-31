import 'package:book_store_app/app/modules/cart/models/cart_item_model.dart';

class CartResponseModel {
  final List<CartItem> items;
  final double subTotal;
  final double total;
  final String currency;

  CartResponseModel({
    required this.items,
    required this.subTotal,
    required this.total,
    required this.currency,
  });
}
