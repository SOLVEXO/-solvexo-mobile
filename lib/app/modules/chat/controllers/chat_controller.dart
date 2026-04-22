// lib/app/modules/chat/chat_controller.dart

import 'package:book_store_app/app/data/services/claude_service.dart';
import 'package:book_store_app/app/data/services/product_context_builder.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/chat/models/chat_message_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class ChatController extends GetxController {
  final ClaudeService _claude = ClaudeService();

  final messages = <ChatMessageModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;

  late String _systemPrompt;
  StreamSubscription<String>? _streamSub;

  @override
  void onInit() {
    super.onInit();
    _initSystemPrompt();
    _addWelcomeMessage();
  }

  Future<void> onRefreshTap() async {
    if (isRefreshing.value) return;

    isRefreshing.value = true;

    clearChat(); // your existing function

    await Future.delayed(const Duration(milliseconds: 600));

    isRefreshing.value = false;
  }

  void _initSystemPrompt() {
    // Pull from your existing product repository / GetX service
    final productController = Get.put(ProductController());
    _systemPrompt = ProductContextBuilder.build(productController.products);
  }

  void _addWelcomeMessage() {
    messages.add(
      ChatMessageModel(
        role: MessageRole.assistant,
        content:
            "Hi! I'm your book assistant 📚 What are you looking for today?",
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isLoading.value) return;

    // 1. Add user bubble
    messages.add(ChatMessageModel(role: MessageRole.user, content: trimmed));
    isLoading.value = true;

    // 2. Add empty assistant bubble (streaming placeholder)
    final assistantMsg = ChatMessageModel(
      role: MessageRole.assistant,
      content: '',
      isStreaming: true,
    );
    messages.add(assistantMsg);

    // 3. Build history for API (all except the empty placeholder)
    final history = messages
        .where((m) => m.content.isNotEmpty)
        .where((m) => !m.isStreaming)
        .where(
          (m) =>
              !(m.role == MessageRole.assistant &&
                  m.content.contains("I'm your book assistant")),
        ) // skip welcome
        .map((m) => m.toApiMap())
        .toList();

    try {
      _streamSub = _claude
          .streamChat(systemPrompt: _systemPrompt, messages: history)
          .listen(
            (token) {
              assistantMsg.content += token;
              messages.refresh(); // ← GetX reactive update
            },
            onDone: () {
              assistantMsg.isStreaming = false;
              isLoading.value = false;
              messages.refresh();
            },
            onError: (_) {
              assistantMsg.content = 'Something went wrong. Please try again.';
              assistantMsg.isStreaming = false;
              isLoading.value = false;
              messages.refresh();
            },
          );
    } catch (e) {
      debugPrint('sendMessage error: $e');
      isLoading.value = false;
    }
  }

  void clearChat() {
    _streamSub?.cancel();
    messages.clear();
    _addWelcomeMessage();
  }

  @override
  void onClose() {
    _streamSub?.cancel();
    super.onClose();
  }
}
