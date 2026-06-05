import 'package:book_store_app/app/modules/seller_payment_methods/controllers/seller_payment_methods_controller.dart';
import 'package:get/get.dart';

class SellerPaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerPaymentMethodsController>(() => SellerPaymentMethodsController());
  }
}
