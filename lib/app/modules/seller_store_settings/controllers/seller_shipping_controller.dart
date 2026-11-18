import 'package:book_store_app/app/data/repositories/seller_store_settings_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:get/get.dart';

/// Shipping (docs 6.13 "shipping page (zones read, delivery days)").
/// Zones are set by Edudeen and are read-only here.
class SellerShippingController extends GetxController {
  SellerShippingController({SellerStoreSettingsRepository? repository})
      : _repo = repository ?? SellerStoreSettingsRepository();
  final SellerStoreSettingsRepository _repo;

  final RxBool isLoading = true.obs;
  final RxBool failed = false.obs;
  final RxList<ShippingZone> zones = <ShippingZone>[].obs;
  final Rx<StoreSettings?> settings = Rx<StoreSettings?>(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    failed.value = false;
    try {
      final storeId = await AppPreferences.getStoreId() ?? '';
      final results = await Future.wait([_repo.zones(), _repo.load(storeId)]);
      zones.assignAll(results[0] as List<ShippingZone>);
      settings.value = results[1] as StoreSettings;
    } catch (_) {
      failed.value = true;
    }
    isLoading.value = false;
  }
}
