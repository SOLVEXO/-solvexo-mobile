import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

// ── Model ──────────────────────────────────────────────────────────────────────

class SellerStore {
  final String id;
  final String name;
  final String category;
  final String initials;
  final bool isActive;
  final int productCount;
  final double totalSales;

  const SellerStore({
    required this.id,
    required this.name,
    required this.category,
    required this.initials,
    this.isActive = true,
    this.productCount = 0,
    this.totalSales = 0,
  });
}

// ── Controller ─────────────────────────────────────────────────────────────────

class SellerStoresController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<SellerStore> stores = <SellerStore>[].obs;

  // Profile
  final RxString userName = 'Seller'.obs;
  final RxString userEmail = ''.obs;
  final RxString userInitials = 'S'.obs;

  // Computed stats
  int get totalProducts => stores.fold(0, (sum, s) => sum + s.productCount);
  double get totalRevenue => stores.fold(0.0, (sum, s) => sum + s.totalSales);

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    _loadStores();
  }

  Future<void> _loadProfile() async {
    final name = await AppPreferences.getUserName();
    final email = await AppPreferences.getUserEmail();
    if (name != null && name.trim().isNotEmpty) {
      userName.value = name.trim();
      final parts = name.trim().split(' ');
      userInitials.value = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }
    if (email != null) userEmail.value = email;
  }

  Future<void> _loadStores() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 700));

    // TODO: Replace with real API call — GET /seller/stores
    // final response = await storeRepository.getMyStores(token);
    // stores.assignAll(response.map((s) => SellerStore.fromJson(s)));

    // Mock: one existing store (remove this when API is connected)
    stores.assignAll([
      const SellerStore(
        id: 'store_001',
        name: 'My EduDeen Store',
        category: 'Education & Learning',
        initials: 'ME',
        isActive: true,
        productCount: 12,
        totalSales: 842.50,
      ),
    ]);

    isLoading.value = false;

    // No stores → go directly to onboarding
    if (stores.isEmpty) {
      Get.offAllNamed(Routes.sellerOnboarding);
    }
  }

  Future<void> refreshStores() async => _loadStores();

  void openStore(SellerStore store) {
    // TODO: save store ID to prefs so SellerHomeController knows which store
    Get.offAllNamed(Routes.sellerHome);
  }

  void createNewStore() {
    Get.toNamed(Routes.sellerOnboarding);
  }
}
