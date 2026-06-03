import 'package:get/get.dart';

enum ProductStatus { all, active, draft, lowStock, outOfStock }

class SellerProduct {
  final String id;
  final String name;
  final String emoji;
  final double price;
  final String type; // 'Digital' | 'Physical'
  final ProductStatus status;
  final int sold;
  final int? stock; // null = unlimited (Digital)

  const SellerProduct({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.type,
    required this.status,
    required this.sold,
    this.stock,
  });

  bool get isUnlimitedStock => stock == null;

  String get stockLabel => isUnlimitedStock ? '∞' : '$stock';
}

class SellerProductsController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<ProductStatus> selectedFilter = ProductStatus.all.obs;
  final RxString searchQuery = ''.obs;

  final List<SellerProduct> _allProducts = const [
    SellerProduct(
      id: 'p001',
      name: 'Grade 5 Math Bundle',
      emoji: '📐',
      price: 49.00,
      type: 'Digital',
      status: ProductStatus.active,
      sold: 847,
      stock: null,
    ),
    SellerProduct(
      id: 'p002',
      name: 'Ceramic Mug Set (2pk)',
      emoji: '☕',
      price: 58.00,
      type: 'Physical',
      status: ProductStatus.active,
      sold: 203,
      stock: 34,
    ),
    SellerProduct(
      id: 'p003',
      name: 'Linen Wall Hanging',
      emoji: '🖼️',
      price: 72.00,
      type: 'Physical',
      status: ProductStatus.lowStock,
      sold: 144,
      stock: 7,
    ),
    SellerProduct(
      id: 'p004',
      name: 'Fractions Mastery Kit',
      emoji: '➗',
      price: 18.00,
      type: 'Digital',
      status: ProductStatus.active,
      sold: 623,
      stock: null,
    ),
    SellerProduct(
      id: 'p005',
      name: 'Science Workbook Gr.5',
      emoji: '🔬',
      price: 22.50,
      type: 'Physical',
      status: ProductStatus.draft,
      sold: 0,
      stock: 100,
    ),
    SellerProduct(
      id: 'p006',
      name: 'Wooden Puzzle Set',
      emoji: '🧩',
      price: 35.00,
      type: 'Physical',
      status: ProductStatus.outOfStock,
      sold: 312,
      stock: 0,
    ),
  ];

  List<SellerProduct> get filteredProducts {
    var list = selectedFilter.value == ProductStatus.all
        ? List<SellerProduct>.from(_allProducts)
        : _allProducts.where((p) => p.status == selectedFilter.value).toList();

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int countFor(ProductStatus status) {
    if (status == ProductStatus.all) return _allProducts.length;
    return _allProducts.where((p) => p.status == status).length;
  }

  void setFilter(ProductStatus status) => selectedFilter.value = status;

  void onSearch(String query) => searchQuery.value = query;

  void clearSearch() => searchQuery.value = '';

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
}
