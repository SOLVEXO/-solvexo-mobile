import 'package:book_store_app/app/modules/store_services/controllers/store_services_controller.dart';
import 'package:get/get.dart';

class StoreServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreServicesController>(() => StoreServicesController());
  }
}
