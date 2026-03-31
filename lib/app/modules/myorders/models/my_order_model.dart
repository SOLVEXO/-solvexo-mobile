import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:book_store_app/app/modules/myorders/models/payment_result.dart';
import 'package:book_store_app/app/modules/myorders/models/shipping_address_model.dart';
import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> orderItems;
  final ShippingAddress shippingAddress;
  final String paymentMethod;
  final PaymentResult? paymentResult;
  final double itemsPrice;
  final double shippingPrice;
  final double taxPrice;
  final double totalPrice;
  final bool isPaid;
  final DateTime? paidAt;
  final bool isDelivered;
  final DateTime? deliveredAt;
  final String orderStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.orderItems,
    required this.shippingAddress,
    required this.paymentMethod,
    this.paymentResult,
    required this.itemsPrice,
    required this.shippingPrice,
    required this.taxPrice,
    required this.totalPrice,
    required this.isPaid,
    this.paidAt,
    required this.isDelivered,
    this.deliveredAt,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderModel(
        id: json['_id'] as String,
        userId: json['user'] is String
            ? json['user'] as String
            : (json['user'] as Map<String, dynamic>)['_id'] as String,
        orderItems: (json['orderItems'] as List)
            .map((item) => OrderItem.fromJson(item))
            .toList(),
        shippingAddress: ShippingAddress.fromJson(json['shippingAddress']),
        paymentMethod: json['paymentMethod'] as String,
        paymentResult: json['paymentResult'] != null
            ? PaymentResult.fromJson(json['paymentResult'])
            : null,
        itemsPrice: (json['itemsPrice'] as num).toDouble(),
        shippingPrice: (json['shippingPrice'] as num).toDouble(),
        taxPrice: (json['taxPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        isPaid: json['isPaid'] as bool,
        paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
        isDelivered: json['isDelivered'] as bool,
        deliveredAt: json['deliveredAt'] != null
            ? DateTime.parse(json['deliveredAt'])
            : null,
        orderStatus: json['orderStatus'] as String,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
    } catch (e) {
      debugPrint('❌ OrderModel parsing error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod,
      'paymentResult': paymentResult?.toJson(),
      'itemsPrice': itemsPrice,
      'shippingPrice': shippingPrice,
      'taxPrice': taxPrice,
      'totalPrice': totalPrice,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
      'isDelivered': isDelivered,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'orderStatus': orderStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get statusDisplay {
    switch (orderStatus) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus;
    }
  }

  String get formattedTotal => '\$${totalPrice.toStringAsFixed(2)}';

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }
}
