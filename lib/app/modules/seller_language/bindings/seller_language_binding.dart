import 'package:book_store_app/app/modules/seller_language/controllers/seller_language_controller.dart';
import 'package:get/get.dart';

class SellerLanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerLanguageController>(() => SellerLanguageController());
  }
}
