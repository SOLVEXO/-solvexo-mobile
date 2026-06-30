import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:book_store_app/app/modules/myorders/models/shipping_address_model.dart';
import 'package:flutter/material.dart';

class OrderModel {
  final String orderId;
  final String orderNumber;
  final String orderStatus;
  final String paymentType;
  final String paymentStatus;
  final bool isPaid;
  final double subtotal;
  final double shippingFee;
  final double taxAmount;
  final double totalAmount;
  final String currency;
  final ShippingAddress shippingAddress;
  final List<OrderStore> stores;
  final DateTime createdAt;
  final DateTime? paidAt;

  const OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentType,
    required this.paymentStatus,
    required this.isPaid,
    required this.subtotal,
    required this.shippingFee,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    required this.shippingAddress,
    required this.stores,
    required this.createdAt,
    this.paidAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderModel(
        orderId: json['orderId'] as String? ?? '',
        orderNumber: json['orderNumber'] as String? ?? '',
        orderStatus: json['orderStatus'] as String? ?? 'pending',
        paymentType: json['paymentType'] as String? ?? '',
        paymentStatus: json['paymentStatus'] as String? ?? 'unpaid',
        isPaid: json['isPaid'] as bool? ?? false,
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
        taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'USD',
        shippingAddress: ShippingAddress.fromJson(
          json['shippingAddress'] as Map<String, dynamic>? ?? {},
        ),
        stores: (json['stores'] as List? ?? [])
            .map((e) => OrderStore.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        paidAt: json['paidAt'] != null
            ? DateTime.tryParse(json['paidAt'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('❌ OrderModel.fromJson error: $e');
      debugPrint('JSON: $json');
      rethrow;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Flat list of all items across all stores
  List<OrderItem> get allItems =>
      stores.expand((s) => s.items).toList();

  /// First item's image, used as the order thumbnail
  String? get thumbnailImage {
    for (final store in stores) {
      for (final item in store.items) {
        if (item.image != null && item.image!.isNotEmpty) return item.image;
      }
    }
    return null;
  }

  int get totalItemCount => stores.fold(0, (s, store) => s + store.itemCount);

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  String get statusDisplay {
    switch (orderStatus) {
      case 'pending':           return 'Pending';
      case 'processing':        return 'Processing';
      case 'shipped':           return 'Shipped';
      case 'partially_shipped': return 'Part. Shipped';
      case 'completed':         return 'Completed';
      case 'cancelled':         return 'Cancelled';
      default:                  return orderStatus;
    }
  }

  Color get statusColor {
    switch (orderStatus) {
      case 'completed':         return const Color(0xFF22C55E);
      case 'shipped':
      case 'partially_shipped': return const Color(0xFF3B82F6);
      case 'processing':        return const Color(0xFFF59E0B);
      case 'cancelled':         return const Color(0xFFEF4444);
      default:                  return const Color(0xFF6B7280);
    }
  }

  bool get isCompleted => orderStatus == 'completed';
  bool get isCancelled => orderStatus == 'cancelled';
  bool get canCancel => orderStatus == 'pending';
}
