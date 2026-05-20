import 'package:flutter/material.dart';

class AddressModel {
  final String? id;
  final String? userId;
  final String label;
  final String recipientName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    this.id,
    this.userId,
    required this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.isDefault = false,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    debugPrint('📍 AddressModel.fromJson: $json');
    return AddressModel(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      label: (json['label'] as String?) ?? 'Home',
      recipientName:
          (json['recipientName'] as String?) ??
          (json['fullName'] as String?) ??
          '',
      phoneNumber:
          (json['phoneNumber'] as String?) ?? (json['phone'] as String?) ?? '',
      addressLine1: (json['addressLine1'] as String?) ?? '',
      addressLine2: json['addressLine2'] as String?,
      city: (json['city'] as String?) ?? '',
      state: (json['state'] as String?) ?? '',
      zipCode: (json['zipCode'] as String?) ?? '',
      isDefault: (json['isDefault'] as bool?) ?? false,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  // ─── Create body: POST /address/add-address ───────────────────────────────
  // No addressId — backend generates it
  Map<String, dynamic> toJson() => {
    'label': label,
    'recipientName': recipientName,
    'phoneNumber': phoneNumber,
    'addressLine1': addressLine1,
    if (addressLine2 != null && addressLine2!.isNotEmpty)
      'addressLine2': addressLine2,
    'city': city,
    'state': state,
    'zipCode': zipCode,
    'isDefault': isDefault,
  };

  // ─── Update body: PUT /address/update-address ─────────────────────────────
  // addressId goes in the BODY for this endpoint
  Map<String, dynamic> toUpdateJson() {
    assert(id != null, 'Cannot call toUpdateJson without an address id');
    return {
      'addressId': id, // ← required by update API
      'label': label,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty)
        'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
    };
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      city,
      state,
      zipCode,
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  String get shortAddress => '$city, $state $zipCode';

  AddressModel copyWith({
    String? id,
    String? userId,
    String? label,
    String? recipientName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zipCode,
    bool? isDefault,
    String? status,
  }) => AddressModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    label: label ?? this.label,
    recipientName: recipientName ?? this.recipientName,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    addressLine1: addressLine1 ?? this.addressLine1,
    addressLine2: addressLine2 ?? this.addressLine2,
    city: city ?? this.city,
    state: state ?? this.state,
    zipCode: zipCode ?? this.zipCode,
    isDefault: isDefault ?? this.isDefault,
    status: status ?? this.status,
  );

  @override
  String toString() =>
      'AddressModel(id: $id, label: $label, '
      'recipient: $recipientName, city: $city, isDefault: $isDefault)';
}
