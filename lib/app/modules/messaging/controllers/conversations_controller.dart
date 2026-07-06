import 'dart:async';

import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/data/repositories/messaging_repository.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:get/get.dart';

/// Buyer's message inbox — lists every store conversation they've started.
class ConversationsController extends GetxController {
  final MessagingRepository _repo = MessagingRepository();

  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoading = true.obs;

  Timer? _pollTimer;
  static const _pollInterval = Duration(seconds: 15);

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    _pollTimer = Timer.periodic(_pollInterval, (_) => loadConversations(silent: true));
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> loadConversations({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    final result = await _repo.getConversations(page: 1, limit: 50);
    conversations.assignAll(result.conversations);
    isLoading.value = false;
  }

  void openChat(ConversationModel c) {
    Get.toNamed(Routes.chatView, arguments: {
      'conversationId': c.id,
      'peerName': c.peerName('user'),
      'peerAvatar': c.peerAvatar('user'),
    });
  }
}
