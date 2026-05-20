class OrderRequestModel {
  final List<OrderItemRequest> orderItems;
  final ShippingAddressRequest shippingAddress;
  final String paymentMethod;
  final double itemsPrice;
  final double shippingPrice;
  final double taxPrice;
  final double totalPrice;

  OrderRequestModel({
    required this.orderItems,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.itemsPrice,
    required this.shippingPrice,
    required this.taxPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod,
      'itemsPrice': itemsPrice,
      'shippingPrice': shippingPrice,
      'taxPrice': taxPrice,
      'totalPrice': totalPrice,
    };
  }
}

class OrderItemRequest {
  final String product;
  final String name;
  final int quantity;
  final double price;
  final String? image;

  OrderItemRequest({
    required this.product,
    required this.name,
    required this.quantity,
    required this.price,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'name': name,
      'quantity': quantity,
      'price': price,
      'image': image,
    };
  }
}

class ShippingAddressRequest {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  // final String country;

  ShippingAddressRequest({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    // required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      // 'country': country,
    };
  }
}
