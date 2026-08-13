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
  final String returnStatus;

  // Denormalized from the parent OrderStore at parse time (see
  // OrderStore.fromJson) — the backend attaches seller info per-store, not
  // per-item, but flat item listings (e.g. OrderItems widget) need it too.
  final String? sellerName;
  final bool sellerVerified;

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
    this.returnStatus = 'none',
    this.sellerName,
    this.sellerVerified = false,
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
      returnStatus: json['returnStatus'] as String? ?? 'none',
    );
  }

  OrderItem withSeller({String? sellerName, bool sellerVerified = false}) =>
      OrderItem(
        itemId: itemId,
        productId: productId,
        name: name,
        image: image,
        sku: sku,
        type: type,
        quantity: quantity,
        price: price,
        totalPrice: totalPrice,
        status: status,
        returnStatus: returnStatus,
        sellerName: sellerName,
        sellerVerified: sellerVerified,
      );
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
  // The SellerOrder subdocument's own _id — distinct from storeId (the
  // Store document's _id) — required by the refund-request API, which
  // scopes each request to exactly one sellerOrder.
  final String sellerOrderId;
  final String? sellerName;
  final bool sellerVerified;
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
    required this.sellerOrderId,
    this.sellerName,
    this.sellerVerified = false,
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
    final sellerName = json['sellerName'] as String?;
    final sellerVerified = json['sellerVerified'] == true;
    return OrderStore(
      storeId: json['storeId'] as String? ?? '',
      sellerOrderId: json['sellerOrderId'] as String? ?? '',
      sellerName: sellerName,
      sellerVerified: sellerVerified,
      fulfillmentType: json['fulfillmentType'] as String? ?? 'physical',
      status: json['status'] as String? ?? 'pending',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>)
              .withSeller(sellerName: sellerName, sellerVerified: sellerVerified))
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
