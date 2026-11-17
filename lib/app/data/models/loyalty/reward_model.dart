class RewardModel {
  final String id;
  final String name;
  final String? description;
  final int pointsCost;
  final String type; // 'fixed_discount' | 'free_product'
  final double? discountValue;
  final String? productId;
  final int? stockLimit;
  final int redeemedCount;
  final bool isActive;

  const RewardModel({
    required this.id,
    required this.name,
    this.description,
    required this.pointsCost,
    required this.type,
    this.discountValue,
    this.productId,
    this.stockLimit,
    required this.redeemedCount,
    required this.isActive,
  });

  bool get isFixedDiscount => type == 'fixed_discount';
  bool get isOutOfStock => stockLimit != null && redeemedCount >= stockLimit!;

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'fixed_discount',
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      productId: json['productId'] as String?,
      stockLimit: json['stockLimit'] as int?,
      redeemedCount: json['redeemedCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
