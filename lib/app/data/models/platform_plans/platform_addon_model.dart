/// An add-on purchase from `GET /api/platform-plans/:storeId/addons`.
class PlatformAddonModel {
  final String id;
  final String addonType;
  final bool recurring;
  final double priceUSD; // total charged (unit price × quantity)
  final int quantity;
  final String status; // 'active' | 'canceled'
  final DateTime? nextBillingDate;

  const PlatformAddonModel({
    required this.id,
    required this.addonType,
    required this.recurring,
    required this.priceUSD,
    required this.quantity,
    required this.status,
    this.nextBillingDate,
  });

  bool get isActive => status == 'active';

  factory PlatformAddonModel.fromJson(Map<String, dynamic> json) {
    return PlatformAddonModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      addonType: json['addonType'] as String? ?? '',
      recurring: json['recurring'] as bool? ?? false,
      priceUSD: (json['priceUSD'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      status: json['status'] as String? ?? 'active',
      nextBillingDate:
          json['nextBillingDate'] != null ? DateTime.tryParse(json['nextBillingDate'].toString()) : null,
    );
  }
}

/// Purchasable add-on catalog — mirrors the backend's `PlatformAddonsService`
/// price table exactly (the API only exposes purchases, not the catalog).
/// If backend prices change, the server still charges its own price; this is
/// display copy only.
class AddonCatalogEntry {
  final String type;
  final String name;
  final String description;
  final double unitPriceUSD;
  final bool recurring;

  const AddonCatalogEntry({
    required this.type,
    required this.name,
    required this.description,
    required this.unitPriceUSD,
    required this.recurring,
  });
}

const List<AddonCatalogEntry> kAddonCatalog = [
  AddonCatalogEntry(
    type: 'extra_ai_credits',
    name: 'Extra AI Credits',
    description: '500 AI Studio credits per pack, one-time',
    unitPriceUSD: 10,
    recurring: false,
  ),
  AddonCatalogEntry(
    type: 'extra_staff_seat',
    name: 'Extra Staff Seat',
    description: 'One additional POS/staff account',
    unitPriceUSD: 5,
    recurring: true,
  ),
  AddonCatalogEntry(
    type: 'priority_marketplace_placement',
    name: 'Priority Marketplace Placement',
    description: 'Boost your store in marketplace listings',
    unitPriceUSD: 29,
    recurring: true,
  ),
  AddonCatalogEntry(
    type: 'advanced_tax_compliance',
    name: 'Advanced Tax Compliance',
    description: 'Automated tax reports and compliance tooling',
    unitPriceUSD: 15,
    recurring: true,
  ),
  AddonCatalogEntry(
    type: 'sms_notifications',
    name: 'SMS Notifications',
    description: 'Order and marketing SMS for your buyers',
    unitPriceUSD: 5,
    recurring: true,
  ),
];

AddonCatalogEntry? addonCatalogEntry(String type) {
  for (final e in kAddonCatalog) {
    if (e.type == type) return e;
  }
  return null;
}
