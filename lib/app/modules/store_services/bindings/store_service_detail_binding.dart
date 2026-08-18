import 'package:book_store_app/app/modules/store_services/controllers/store_service_detail_controller.dart';
import 'package:get/get.dart';

class StoreServiceDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreServiceDetailController>(() => StoreServiceDetailController());
  }
}
