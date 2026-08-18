import 'package:book_store_app/app/data/models/bookings/bookable_service_model.dart';
import 'package:book_store_app/app/data/models/bookings/service_address_model.dart';

class BookingBuyerModel {
  final String name;
  final String? email;
  final String? profileImage;

  const BookingBuyerModel({required this.name, this.email, this.profileImage});

  factory BookingBuyerModel.fromJson(Map<String, dynamic> json) {
    return BookingBuyerModel(
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
    );
  }
}

class BookingModel {
  final String id;
  final String serviceId;
  final String? packagePurchaseId;
  final String sellerId;
  final String storeId;
  final String buyerId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String locationType; // 'in_person' | 'virtual' | 'customer_address'
  final ServiceAddressModel? serviceAddress;
  final String? meetingLink;
  final double price;
  final String currency;
  final String status;
  final String? cancellationReason;
  final String? buyerNote;
  final BookableServiceModel? service;
  final BookingBuyerModel? buyer;

  const BookingModel({
    required this.id,
    required this.serviceId,
    this.packagePurchaseId,
    required this.sellerId,
    required this.storeId,
    required this.buyerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.locationType,
    this.serviceAddress,
    this.meetingLink,
    required this.price,
    this.currency = 'USD',
    this.status = 'pending_payment',
    this.cancellationReason,
    this.buyerNote,
    this.service,
    this.buyer,
  });

  bool get isCancellable => status == 'pending_payment' || status == 'confirmed';
  bool get isReschedulable => status == 'confirmed';
  bool get isPaidFromPackage => packagePurchaseId != null;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      packagePurchaseId: json['packagePurchaseId'] as String?,
      sellerId: json['sellerId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      locationType: json['locationType'] as String? ?? 'in_person',
      serviceAddress: json['serviceAddress'] != null
          ? ServiceAddressModel.fromJson(json['serviceAddress'] as Map<String, dynamic>)
          : null,
      meetingLink: json['meetingLink'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'pending_payment',
      cancellationReason: json['cancellationReason'] as String?,
      buyerNote: json['buyerNote'] as String?,
      service: json['service'] != null ? BookableServiceModel.fromJson(json['service'] as Map<String, dynamic>) : null,
      buyer: json['buyer'] != null ? BookingBuyerModel.fromJson(json['buyer'] as Map<String, dynamic>) : null,
    );
  }
}
