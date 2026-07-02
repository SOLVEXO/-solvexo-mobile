import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:get/get.dart';

class SellerFinanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerFinanceController>(() => SellerFinanceController());
  }
}
