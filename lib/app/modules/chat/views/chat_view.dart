// lib/app/modules/chat/chat_view.dart

import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/chat/controllers/chat_controller.dart';
import 'package:book_store_app/app/modules/chat/models/chat_message_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final inputCtrl = TextEditingController();
    final scrollCtrl = ScrollController();

    void scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollCtrl.hasClients) {
          scrollCtrl.animateTo(
            scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }

    return Scaffold(
      appBar: CustomAppBarTwo(
        title: "Book Assistant",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Obx(() {
              return AnimatedRotation(
                turns: controller.isRefreshing.value ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: SvgIcon(
                  assetName: AppIcons.refreshIcon,
                  onTap: controller.onRefreshTap,
                  size: 20,
                ),
              );
            }),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Message list ──────────────────────────────
          Expanded(
            child: Obx(() {
              scrollToBottom();
              return ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: controller.messages.length,
                itemBuilder: (_, i) => _Bubble(msg: controller.messages[i]),
              );
            }),
          ),

          // ── Input bar ────────────────────────────────
          Obx(
            () => _InputBar(
              controller: inputCtrl,
              isLoading: controller.isLoading.value,
              onSend: (text) {
                controller.sendMessage(text);
                inputCtrl.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bubble ───────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final ChatMessageModel msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == MessageRole.user;
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? scheme.primary : scheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: msg.isStreaming && msg.content.isEmpty
            ? SizedBox(
                width: 36,
                child: Text(
                  '...',
                  style: TextStyle(
                    fontSize: 22,
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 3,
                  ),
                ),
              )
            : Text(
                msg.content,
                style: TextStyle(
                  color: isUser ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final void Function(String) onSend;
  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: isLoading ? null : onSend,
                decoration: InputDecoration(
                  hintText: 'Search books, ask for recs...',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton.filled(
                    onPressed: () => onSend(controller.text),
                    icon: const Icon(Icons.send_rounded),
                  ),
          ],
        ),
      ),
    );
  }
}
