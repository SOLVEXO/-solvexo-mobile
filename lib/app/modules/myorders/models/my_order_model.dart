import 'package:book_store_app/app/data/models/enums/enums.dart';

class OrderModel {
  final String orderNumber;
  final DateTime date;
  final String productName;
  final String image;
  final int totalItems;
  final double totalAmount;
  final OrderStatus status;
  final bool isReviewed;

  OrderModel({
    required this.orderNumber,
    required this.date,
    required this.productName,
    required this.image,
    required this.totalItems,
    required this.totalAmount,
    required this.status,
    this.isReviewed = false,
  });
}
