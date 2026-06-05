import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerChatController extends GetxController {
  late final SellerConversation conversation;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isSending = false.obs;
  final TextEditingController inputCtrl = TextEditingController();
  final RxString inputText = ''.obs;
  final ScrollController scrollCtrl = ScrollController();

  @override
  void onInit() {
    super.onInit();
    conversation = Get.arguments as SellerConversation;
    _loadMessages();
  }

  void _loadMessages() {
    final msgs = kMockMessages[conversation.id] ?? [];
    messages.assignAll(msgs);
  }

  void onTextChanged(String value) => inputText.value = value;

  void sendMessage() {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.period.name.toUpperCase()}';

    messages.add(ChatMessage(
      id: 'new_${messages.length}',
      text: text,
      time: timeStr,
      date: 'Today',
      isSeller: true,
      isRead: false,
    ));

    inputCtrl.clear();
    inputText.value = '';

    // Scroll to bottom (the list is reversed so top = latest)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    inputCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }
}
