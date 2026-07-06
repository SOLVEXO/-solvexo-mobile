import 'package:book_store_app/app/modules/messaging/controllers/conversations_controller.dart';
import 'package:get/get.dart';

class ConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationsController>(() => ConversationsController());
  }
}
