import 'package:book_store_app/app/data/models/bookings/bookable_service_model.dart';
import 'package:book_store_app/app/data/repositories/bookings_repository.dart';
import 'package:get/get.dart';

/// Public, storeId-scoped list of a store's bookable services — the buyer
/// lands here from the storefront's services teaser or directly, and taps
/// through to a service's booking screen.
class StoreServicesController extends GetxController {
  final BookingsRepository _repo = BookingsRepository();

  late final String storeId;
  late final String storeName;

  final RxBool isLoading = true.obs;
  final RxList<BookableServiceModel> services = <BookableServiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _readArgs();
    _load();
  }

  void _readArgs() {
    final args = Get.arguments;
    if (args is Map) {
      storeId = args['storeId'] as String? ?? '';
      storeName = args['storeName'] as String? ?? 'Store';
    } else {
      storeId = '';
      storeName = 'Store';
    }
  }

  Future<void> _load() async {
    if (storeId.isEmpty) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    services.assignAll(await _repo.browseStoreServices(storeId));
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => _load();
}
