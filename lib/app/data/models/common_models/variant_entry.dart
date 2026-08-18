import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One attribute row within a variant card, e.g. Color: Red.
class VariantOptionEntry {
  final TextEditingController nameCtrl;
  final TextEditingController valueCtrl;

  VariantOptionEntry({String name = '', String value = ''})
      : nameCtrl = TextEditingController(text: name),
        valueCtrl = TextEditingController(text: value);

  void dispose() {
    nameCtrl.dispose();
    valueCtrl.dispose();
  }
}

/// A single variant being authored/edited in the seller Add/Edit Product
/// screens — mirrors the backend's CreateVariantDto/UpdateVariantDto shape.
class VariantEntry {
  final TextEditingController priceCtrl;
  final TextEditingController compareAtPriceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController shippingWeightCtrl;
  final RxBool unlimitedStock = false.obs;
  final RxBool isDefault = false.obs;
  final RxList<String> images = <String>[].obs;
  final RxBool isUploadingImage = false.obs;
  final RxList<VariantOptionEntry> options = <VariantOptionEntry>[].obs;

  // Set once this variant has been created server-side (Edit Product flow
  // only) — null means it only exists locally and needs a POST on save.
  String? remoteId;

  VariantEntry({String price = ''})
      : priceCtrl = TextEditingController(text: price),
        compareAtPriceCtrl = TextEditingController(),
        stockCtrl = TextEditingController(),
        shippingWeightCtrl = TextEditingController();

  void addOption() => options.add(VariantOptionEntry());

  void removeOption(int index) {
    if (index < options.length) {
      final removed = options.removeAt(index);
      WidgetsBinding.instance.addPostFrameCallback((_) => removed.dispose());
    }
  }

  void dispose() {
    priceCtrl.dispose();
    compareAtPriceCtrl.dispose();
    stockCtrl.dispose();
    shippingWeightCtrl.dispose();
    for (final o in options) {
      o.dispose();
    }
  }

  /// Builds the request payload for this variant, or null if the price
  /// doesn't parse (caller surfaces a toast and aborts on null).
  Map<String, dynamic>? toJson() {
    final price = double.tryParse(priceCtrl.text.trim());
    if (price == null) return null;
    return {
      'price': price,
      'compareAtPrice': double.tryParse(compareAtPriceCtrl.text.trim()),
      'options': options
          .where((o) => o.nameCtrl.text.trim().isNotEmpty && o.valueCtrl.text.trim().isNotEmpty)
          .map((o) => {'name': o.nameCtrl.text.trim(), 'value': o.valueCtrl.text.trim()})
          .toList(),
      'stock': unlimitedStock.value ? 0 : (int.tryParse(stockCtrl.text.trim()) ?? 0),
      'unlimitedStock': unlimitedStock.value,
      'shippingWeight': shippingWeightCtrl.text.trim().isEmpty ? null : shippingWeightCtrl.text.trim(),
      'images': images.toList(),
      'isDefault': isDefault.value,
    };
  }
}
