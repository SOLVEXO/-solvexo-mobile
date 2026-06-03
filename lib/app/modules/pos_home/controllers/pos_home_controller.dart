import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosProduct {
  final String name;
  final double price;
  final String emoji;
  final String category;
  final bool inStock;

  const PosProduct({
    required this.name,
    required this.price,
    required this.emoji,
    required this.category,
    this.inStock = true,
  });
}

class PosHomeController extends GetxController {
  final RxString selectedCategory = 'All'.obs;
  final RxString searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = const [
    'All',
    'Ceramics',
    'Prints',
    'Candles',
    'Accessories',
  ];

  final List<PosProduct> allProducts = const [
    PosProduct(name: 'Ceramic Mug', price: 28, emoji: '☕', category: 'Ceramics'),
    PosProduct(name: 'Linen Tote', price: 42, emoji: '👜', category: 'Accessories'),
    PosProduct(name: 'Wall Print A3', price: 18, emoji: '🖼️', category: 'Prints'),
    PosProduct(name: 'Scented Candle', price: 24, emoji: '🕯️', category: 'Candles', inStock: false),
    PosProduct(name: 'Cork Coasters (4pk)', price: 16, emoji: '🪨', category: 'Accessories'),
    PosProduct(name: 'Hand Lotion 100ml', price: 14, emoji: '🧴', category: 'Accessories'),
    PosProduct(name: 'Bamboo Pen Set', price: 22, emoji: '✏️', category: 'Accessories'),
    PosProduct(name: 'Photo Book S', price: 36, emoji: '📷', category: 'Prints'),
    PosProduct(name: 'Silk Scrunchie 3pk', price: 12, emoji: '🎀', category: 'Accessories'),
    PosProduct(name: 'Travel Journal', price: 20, emoji: '📔', category: 'Accessories'),
    PosProduct(name: 'Essential Oil 30ml', price: 19, emoji: '💧', category: 'Accessories'),
    PosProduct(name: 'Macrame Keyring', price: 10, emoji: '🗝️', category: 'Accessories'),
    PosProduct(name: 'Ceramic Bowl Set', price: 34, emoji: '🍜', category: 'Ceramics'),
    PosProduct(name: 'Beeswax Candle', price: 22, emoji: '🐝', category: 'Candles'),
    PosProduct(name: 'Washi Tape Set', price: 15, emoji: '📐', category: 'Accessories'),
  ];

  List<PosProduct> get filteredProducts {
    return allProducts.where((p) {
      final matchesCategory =
          selectedCategory.value == 'All' || p.category == selectedCategory.value;
      final matchesSearch = searchText.value.isEmpty ||
          p.name.toLowerCase().contains(searchText.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void selectCategory(String category) => selectedCategory.value = category;

  void onSearchChanged(String value) => searchText.value = value;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
