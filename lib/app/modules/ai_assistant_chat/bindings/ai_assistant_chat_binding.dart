import 'package:book_store_app/app/data/services/claude_service.dart';
import 'package:get/get.dart';

import '../controllers/ai_assistant_chat_controller.dart';

class AiAssistantChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiAssistantChatController>(() => AiAssistantChatController());
    Get.lazyPut(() => ClaudeService());
  }
}
