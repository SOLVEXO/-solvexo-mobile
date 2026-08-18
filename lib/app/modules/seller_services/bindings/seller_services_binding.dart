import 'package:book_store_app/app/modules/seller_services/controllers/seller_services_controller.dart';
import 'package:get/get.dart';

class SellerServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerServicesController>(() => SellerServicesController());
  }
}
