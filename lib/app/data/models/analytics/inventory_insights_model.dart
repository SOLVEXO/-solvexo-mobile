class InventoryProductEntry {
  final String productId;
  final String name;
  final int? currentStock;
  final int unitsSoldLast30Days;
  final double? sellThroughRatePercent;
  final double? estimatedWeeksRemaining;

  const InventoryProductEntry({
    required this.productId,
    required this.name,
    this.currentStock,
    required this.unitsSoldLast30Days,
    this.sellThroughRatePercent,
    this.estimatedWeeksRemaining,
  });

  factory InventoryProductEntry.fromJson(Map<String, dynamic> json) {
    return InventoryProductEntry(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      currentStock: json['currentStock'] as int?,
      unitsSoldLast30Days: json['unitsSoldLast30Days'] as int? ?? 0,
      sellThroughRatePercent: (json['sellThroughRatePercent'] as num?)?.toDouble(),
      estimatedWeeksRemaining: (json['estimatedWeeksRemaining'] as num?)?.toDouble(),
    );
  }
}

class InventoryInsightsModel {
  final String note;
  final List<InventoryProductEntry> outOfStock;
  final List<InventoryProductEntry> fastMoving;
  final List<InventoryProductEntry> slowMoving;
  final List<InventoryProductEntry> reorderSuggestions;

  const InventoryInsightsModel({
    required this.note,
    required this.outOfStock,
    required this.fastMoving,
    required this.slowMoving,
    required this.reorderSuggestions,
  });

  static const empty = InventoryInsightsModel(note: '', outOfStock: [], fastMoving: [], slowMoving: [], reorderSuggestions: []);

  factory InventoryInsightsModel.fromJson(Map<String, dynamic> json) {
    List<InventoryProductEntry> parse(String key) =>
        (json[key] as List? ?? []).cast<Map<String, dynamic>>().map(InventoryProductEntry.fromJson).toList();

    return InventoryInsightsModel(
      note: json['note'] as String? ?? '',
      outOfStock: parse('outOfStock'),
      fastMoving: parse('fastMoving'),
      slowMoving: parse('slowMoving'),
      reorderSuggestions: parse('reorderSuggestions'),
    );
  }
}
