import 'package:book_store_app/app/data/models/bookings/service_address_model.dart';
import 'package:book_store_app/app/data/models/bookings/service_package_model.dart';

class BookableServiceModel {
  final String id;
  final String sellerId;
  final String storeId;
  final String name;
  final String slug;
  final String? description;
  final List<String> images;
  final String? categoryId;
  final int durationMinutes;
  final double price;
  final String currency;
  final int capacityPerSlot;
  final int cancellationWindowHours;
  final List<String> locationTypes; // 'in_person' | 'virtual' | 'customer_address'
  final ServiceAddressModel? inPersonAddress;
  final String status; // 'active' | 'inactive' | 'draft'
  // Only populated by the public `getServiceDetail` response (it embeds the
  // service's active packages directly) — null elsewhere, e.g. list views.
  final List<ServicePackageModel>? packages;
  // Seller-side only (list/get/update) — true once at least one weekly-hours
  // rule exists. A service with no availability is never actually bookable.
  final bool hasAvailability;

  const BookableServiceModel({
    required this.id,
    required this.sellerId,
    required this.storeId,
    required this.name,
    required this.slug,
    this.description,
    this.images = const [],
    this.categoryId,
    required this.durationMinutes,
    required this.price,
    this.currency = 'USD',
    this.capacityPerSlot = 1,
    this.cancellationWindowHours = 24,
    this.locationTypes = const [],
    this.inPersonAddress,
    this.status = 'draft',
    this.packages,
    this.hasAvailability = false,
  });

  bool get isActive => status == 'active';
  bool get isGroupService => capacityPerSlot > 1;

  factory BookableServiceModel.fromJson(Map<String, dynamic> json) {
    return BookableServiceModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      storeId: json['storeId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      images: (json['images'] as List? ?? []).cast<String>(),
      categoryId: json['categoryId'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      capacityPerSlot: (json['capacityPerSlot'] as num?)?.toInt() ?? 1,
      cancellationWindowHours: (json['cancellationWindowHours'] as num?)?.toInt() ?? 24,
      locationTypes: (json['locationTypes'] as List? ?? []).cast<String>(),
      inPersonAddress: json['inPersonAddress'] != null
          ? ServiceAddressModel.fromJson(json['inPersonAddress'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'draft',
      packages: json['packages'] != null
          ? (json['packages'] as List).cast<Map<String, dynamic>>().map(ServicePackageModel.fromJson).toList()
          : null,
      hasAvailability: json['hasAvailability'] as bool? ?? false,
    );
  }
}
