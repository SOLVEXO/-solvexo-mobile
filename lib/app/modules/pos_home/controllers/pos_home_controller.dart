import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ── Colours used only in POS dark theme ──────────────────────────────────────
const kPosBg = Color(0xFF1A1A1A);
const kPosSurface = Color(0xFF252525);
const kPosBorder = Color(0xFF333333);
const kPosSubText = Color(0xFF888888);
const kPosText = Color(0xFFE8E8E8);
const kPosOrange = Color(0xFFd97757);
const kPosGreen = Color(0xFF4CAF50);
const kPosRed = Color(0xFFEF5350);

// ── Models ────────────────────────────────────────────────────────────────────

class PosProduct {
  final String name;
  final String sku;
  final double price;
  final String emoji;
  final String category;
  final int? stock; // null = unlimited

  const PosProduct({
    required this.name,
    required this.sku,
    required this.price,
    required this.emoji,
    required this.category,
    this.stock,
  });

  bool get inStock => stock == null || stock! > 0;
  bool get isLowStock => stock != null && stock! > 0 && stock! <= 10;
  bool get isOutOfStock => stock != null && stock! == 0;
}

class CartItem {
  final PosProduct product;
  final RxInt quantity;

  CartItem({required this.product, int qty = 1}) : quantity = qty.obs;

  double get lineTotal => product.price * quantity.value;
}

class HeldSale {
  final String label;
  final double total;
  final String time;

  const HeldSale({required this.label, required this.total, required this.time});
}

// ── Controller ────────────────────────────────────────────────────────────────

class PosHomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final RxString selectedCategory = 'All'.obs;
  final RxString searchText = ''.obs;
  final RxString selectedPayment = 'Card'.obs;
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxList<HeldSale> heldSales = <HeldSale>[].obs;

  static const double taxRate = 0.08;

  final List<String> categories = const [
    'All', 'Ceramics', 'Accessories', 'Prints', 'Candles', 'Stationery',
  ];

  final List<String> paymentMethods = const ['Card', 'Cash', 'Tap', 'Split'];

  final List<PosProduct> allProducts = const [
    PosProduct(name: 'Ceramic Mug',       sku: 'MUG-001', price: 28, emoji: '☕',  category: 'Ceramics'),
    PosProduct(name: 'Linen Tote',         sku: 'TOT-002', price: 42, emoji: '👜',  category: 'Accessories'),
    PosProduct(name: 'Wall Print A3',      sku: 'PRT-003', price: 18, emoji: '🖼️', category: 'Prints'),
    PosProduct(name: 'Scented Candle',     sku: 'CND-004', price: 24, emoji: '🕯️', category: 'Candles', stock: 0),
    PosProduct(name: 'Cork Coasters (4pk)',sku: 'CST-005', price: 16, emoji: '🪨',  category: 'Accessories'),
    PosProduct(name: 'Hand Lotion 100ml',  sku: 'LOT-006', price: 14, emoji: '🧴',  category: 'Accessories'),
    PosProduct(name: 'Bamboo Pen Set',     sku: 'PEN-007', price: 22, emoji: '✏️', category: 'Stationery'),
    PosProduct(name: 'Photo Book S',       sku: 'PHO-008', price: 36, emoji: '📷',  category: 'Prints', stock: 8),
    PosProduct(name: 'Silk Scrunchie 3pk', sku: 'SCR-009', price: 12, emoji: '🎀',  category: 'Accessories'),
    PosProduct(name: 'Travel Journal',     sku: 'JRN-010', price: 20, emoji: '📔',  category: 'Stationery'),
    PosProduct(name: 'Essential Oil 30ml', sku: 'OIL-011', price: 19, emoji: '💧',  category: 'Accessories'),
    PosProduct(name: 'Macrame Keyring',    sku: 'KEY-012', price: 10, emoji: '🗝️', category: 'Accessories'),
    PosProduct(name: 'Ceramic Bowl Set',   sku: 'BWL-013', price: 55, emoji: '🍜',  category: 'Ceramics', stock: 7),
    PosProduct(name: 'Beeswax Candle',     sku: 'BCN-014', price: 18, emoji: '🐝',  category: 'Candles'),
    PosProduct(name: 'Washi Tape Set',     sku: 'WST-015', price: 15, emoji: '📐',  category: 'Stationery'),
    PosProduct(name: 'Linen Napkins (4pk)',sku: 'LNP-016', price: 28, emoji: '🍽️', category: 'Accessories'),
  ];

  // ── Computed ──────────────────────────────────────────────────────────────

  List<PosProduct> get filteredProducts {
    return allProducts.where((p) {
      final matchCat = selectedCategory.value == 'All' || p.category == selectedCategory.value;
      final matchSearch = searchText.value.isEmpty ||
          p.name.toLowerCase().contains(searchText.value.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchText.value.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  double get subtotal => cartItems.fold(0.0, (sum, i) => sum + i.lineTotal);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax;
  int get itemCount => cartItems.fold(0, (sum, i) => sum + i.quantity.value);
  bool get hasItems => cartItems.isNotEmpty;

  int cartQtyFor(PosProduct p) {
    final match = cartItems.firstWhereOrNull((c) => c.product.sku == p.sku);
    return match?.quantity.value ?? 0;
  }

  // ── Cart actions ──────────────────────────────────────────────────────────

  void addToCart(PosProduct product) {
    if (!product.inStock) return;
    final idx = cartItems.indexWhere((c) => c.product.sku == product.sku);
    if (idx >= 0) {
      cartItems[idx].quantity.value++;
    } else {
      cartItems.add(CartItem(product: product));
    }
    cartItems.refresh();
  }

  void removeFromCart(CartItem item) {
    cartItems.remove(item);
  }

  void increment(CartItem item) {
    item.quantity.value++;
    cartItems.refresh();
  }

  void decrement(CartItem item) {
    if (item.quantity.value <= 1) {
      cartItems.remove(item);
    } else {
      item.quantity.value--;
      cartItems.refresh();
    }
  }

  void clearSale() {
    cartItems.clear();
    noteController.clear();
  }

  void holdSale() {
    if (!hasItems) return;
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    heldSales.add(HeldSale(label: 'Walk-in', total: total, time: '$h:$m $period'));
    clearSale();
  }

  void selectPayment(String method) => selectedPayment.value = method;
  void selectCategory(String cat) => selectedCategory.value = cat;
  void onSearchChanged(String v) => searchText.value = v;

  @override
  void onClose() {
    searchController.dispose();
    noteController.dispose();
    super.onClose();
  }
}
