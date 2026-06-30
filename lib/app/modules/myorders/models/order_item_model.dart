class OrderItem {
  final String itemId;
  final String productId;
  final String name;
  final String? image;
  final String? sku;
  final String type;
  final int quantity;
  final double price;
  final double totalPrice;
  final String status;

  const OrderItem({
    required this.itemId,
    required this.productId,
    required this.name,
    this.image,
    this.sku,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.status,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      sku: json['sku'] as String?,
      type: json['type'] as String? ?? 'physical',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class OrderTracking {
  final String carrier;
  final String trackingNumber;
  final String? trackingUrl;

  const OrderTracking({
    required this.carrier,
    required this.trackingNumber,
    this.trackingUrl,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      carrier: json['carrier'] as String? ?? '',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      trackingUrl: json['trackingUrl'] as String?,
    );
  }
}

class OrderStore {
  final String storeId;
  final String fulfillmentType;
  final String status;
  final double subtotal;
  final int itemCount;
  final List<OrderItem> items;
  final OrderTracking? tracking;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  const OrderStore({
    required this.storeId,
    required this.fulfillmentType,
    required this.status,
    required this.subtotal,
    required this.itemCount,
    required this.items,
    this.tracking,
    this.shippedAt,
    this.deliveredAt,
  });

  factory OrderStore.fromJson(Map<String, dynamic> json) {
    return OrderStore(
      storeId: json['storeId'] as String? ?? '',
      fulfillmentType: json['fulfillmentType'] as String? ?? 'physical',
      status: json['status'] as String? ?? 'pending',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      tracking: json['tracking'] != null
          ? OrderTracking.fromJson(json['tracking'] as Map<String, dynamic>)
          : null,
      shippedAt: json['shippedAt'] != null
          ? DateTime.tryParse(json['shippedAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'] as String)
          : null,
    );
  }

  List<OrderItem> get allItems => items;
}
