import 'package:book_store_app/app/modules/seller_messages/controllers/seller_chat_controller.dart';
import 'package:get/get.dart';

class SellerChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerChatController>(() => SellerChatController());
  }
}
