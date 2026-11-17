import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:get/get.dart';

class SellerMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerMessagesController>(() => SellerMessagesController());
  }
}
