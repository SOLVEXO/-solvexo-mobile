import 'package:book_store_app/app/modules/category/models/product_model.dart';

class RefundModel {
  final String id;
  final String orderId;
  final String orderNumber; // ✅ Added orderNumber
  final List<ProductModel> productIds;
  final String reason;
  final String? description;
  final String status;
  final List<String> attachments;
  final double refundAmount; // ✅ Added refundAmount
  final DateTime createdAt;
  final DateTime? updatedAt; // ✅ Added updatedAt

  RefundModel({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.productIds,
    required this.reason,
    this.description,
    required this.status,
    required this.attachments,
    required this.refundAmount,
    required this.createdAt,
    this.updatedAt,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    // ✅ FIX: Handle both populated and non-populated order field
    String extractedOrderId;
    if (json['order'] is String) {
      // If order is just an ID string
      extractedOrderId = json['order'] as String;
    } else if (json['order'] is Map<String, dynamic>) {
      // If order is populated (an object)
      extractedOrderId = json['order']['_id'] as String;
    } else {
      extractedOrderId = '';
    }

    return RefundModel(
      id: json['_id'] as String,
      orderId: extractedOrderId,
      orderNumber: json['orderNumber'] as String? ?? extractedOrderId,
      productIds: (json['productIds'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reason: json['reason'] as String,
      description: json['message'] as String?,
      status: json['status'] as String,
      attachments: List<String>.from(json['images'] ?? []),
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'productIds': productIds.map((p) => p.toJson()).toList(),
      'reason': reason,
      'message': description,
      'status': status,
      'images': attachments,
      'refundAmount': refundAmount,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // ✅ Helper getters
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'reviewing':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get canCancel => status == 'pending';
}
