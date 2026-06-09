import 'package:flutter/material.dart';

// ── Register / Shift sub-models ───────────────────────────────────────────────

class StoreRegister {
  final String id;
  final String name;
  final double defaultFloatCash;
  final String status;

  const StoreRegister({
    required this.id,
    required this.name,
    required this.defaultFloatCash,
    required this.status,
  });

  factory StoreRegister.fromJson(Map<String, dynamic> json) => StoreRegister(
    id: json['_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    defaultFloatCash: (json['defaultFloatCash'] as num?)?.toDouble() ?? 0,
    status: json['status'] as String? ?? '',
  );
}

class StoreShift {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final List<int> daysOfWeek;
  final String status;

  const StoreShift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.status,
  });

  factory StoreShift.fromJson(Map<String, dynamic> json) => StoreShift(
    id: json['_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    startTime: json['startTime'] as String? ?? '',
    endTime: json['endTime'] as String? ?? '',
    daysOfWeek: List<int>.from(json['daysOfWeek'] ?? []),
    status: json['status'] as String? ?? '',
  );
}

// ── Main model ────────────────────────────────────────────────────────────────

class StoreModel {
  final String id;
  final String sellerId;
  final String name;
  final String slug;
  final String logo;
  final String categoryId;
  final String description;
  final String sellerType;
  final List<String> productTypes;
  final List<String> enabledTools;
  final String plan;
  final int aiCredits;
  final String status;
  final bool isDelete;
  final List<StoreRegister> registers;
  final List<StoreShift> shifts;
  final String sellerName;
  final String sellerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoreModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.slug,
    required this.logo,
    required this.categoryId,
    required this.description,
    required this.sellerType,
    required this.productTypes,
    required this.enabledTools,
    required this.plan,
    required this.aiCredits,
    required this.status,
    required this.isDelete,
    required this.registers,
    required this.shifts,
    required this.sellerName,
    required this.sellerEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active' && !isDelete;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'S';
  }

  /// Human-readable seller type label (e.g. "creator" → "Creator")
  String get sellerTypeLabel => sellerType.isNotEmpty
      ? sellerType[0].toUpperCase() + sellerType.substring(1)
      : '';

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    try {
      return StoreModel(
        id: json['_id'] as String? ?? '',
        sellerId: json['sellerId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        logo: json['logo'] as String? ?? '',
        categoryId: json['categoryId'] as String? ?? '',
        description: json['description'] as String? ?? '',
        sellerType: json['sellerType'] as String? ?? '',
        productTypes: List<String>.from(json['productTypes'] ?? []),
        enabledTools: List<String>.from(json['enabledTools'] ?? []),
        plan: json['plan'] as String? ?? '',
        aiCredits: json['aiCredits'] as int? ?? 0,
        status: json['status'] as String? ?? '',
        isDelete: json['isDelete'] as bool? ?? false,
        registers:
            (json['registers'] as List<dynamic>?)
                ?.map((e) => StoreRegister.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        shifts:
            (json['shifts'] as List<dynamic>?)
                ?.map((e) => StoreShift.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        sellerName: json['sellerName'] as String? ?? '',
        sellerEmail: json['sellerEmail'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ StoreModel.fromJson error: $e  json: $json');
      rethrow;
    }
  }
}
