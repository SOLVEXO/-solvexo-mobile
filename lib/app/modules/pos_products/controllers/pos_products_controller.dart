import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosProductItem {
  final String name;
  final String sku;
  final String category;
  final String emoji;
  final double price;
  final int stockCount;

  const PosProductItem({
    required this.name,
    required this.sku,
    required this.category,
    required this.emoji,
    required this.price,
    required this.stockCount,
  });

  bool get inStock => stockCount > 0;
}

class PosProductsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();

  static const List<PosProductItem> _allProducts = [
    PosProductItem(name: 'Ceramic Mug', sku: 'MUG-001', category: 'Ceramics', emoji: '☕', price: 28.00, stockCount: 34),
    PosProductItem(name: 'Linen Tote', sku: 'TOT-002', category: 'Accessories', emoji: '👜', price: 42.00, stockCount: 18),
    PosProductItem(name: 'Wall Print A3', sku: 'PRT-003', category: 'Prints', emoji: '🖼️', price: 18.00, stockCount: 52),
    PosProductItem(name: 'Scented Candle', sku: 'CND-004', category: 'Candles', emoji: '🕯️', price: 24.00, stockCount: 0),
    PosProductItem(name: 'Cork Coasters (4pk)', sku: 'CST-005', category: 'Accessories', emoji: '🪨', price: 16.00, stockCount: 29),
    PosProductItem(name: 'Hand Lotion 100ml', sku: 'LOT-006', category: 'Accessories', emoji: '🧴', price: 14.00, stockCount: 45),
    PosProductItem(name: 'Bamboo Pen Set', sku: 'PEN-007', category: 'Accessories', emoji: '✏️', price: 22.00, stockCount: 11),
    PosProductItem(name: 'Photo Book S', sku: 'PHB-008', category: 'Prints', emoji: '📷', price: 36.00, stockCount: 7),
    PosProductItem(name: 'Silk Scrunchie 3pk', sku: 'SCR-009', category: 'Accessories', emoji: '🎀', price: 12.00, stockCount: 23),
    PosProductItem(name: 'Travel Journal', sku: 'JRN-010', category: 'Accessories', emoji: '📔', price: 20.00, stockCount: 15),
    PosProductItem(name: 'Essential Oil 30ml', sku: 'EOL-011', category: 'Accessories', emoji: '💧', price: 19.00, stockCount: 0),
    PosProductItem(name: 'Macrame Keyring', sku: 'KEY-012', category: 'Accessories', emoji: '🗝️', price: 10.00, stockCount: 41),
    PosProductItem(name: 'Ceramic Bowl Set', sku: 'BWL-013', category: 'Ceramics', emoji: '🍜', price: 34.00, stockCount: 8),
    PosProductItem(name: 'Beeswax Candle', sku: 'BCN-014', category: 'Candles', emoji: '🐝', price: 22.00, stockCount: 19),
    PosProductItem(name: 'Washi Tape Set', sku: 'WSH-015', category: 'Accessories', emoji: '📐', price: 15.00, stockCount: 36),
  ];

  List<PosProductItem> get filteredProducts {
    final query = searchText.value.toLowerCase().trim();
    if (query.isEmpty) return _allProducts;
    return _allProducts.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.sku.toLowerCase().contains(query);
    }).toList();
  }

  void onSearchChanged(String value) => searchText.value = value;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    isLoading.value = false;
  }

  Future<void> refreshData() async => _load();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
