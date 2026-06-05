import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_chat_controller.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/chat_bubble.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/chat_input_bar.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerChatView extends StatelessWidget {
  SellerChatView({super.key});

  final SellerChatController controller = Get.put(SellerChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ChatAppBar(controller: controller),
      body: Column(
        children: [
          Expanded(child: _MessageList(controller: controller)),
          const Divider(height: 1, color: AppColors.lightGrey2),
          ChatInputBar(controller: controller),
        ],
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SellerChatController controller;
  const _ChatAppBar({required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final conv = controller.conversation;
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: Get.back,
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.white, size: 20),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _HeaderAvatar(
            initials: conv.buyerInitials,
            isOnline: conv.isOnline,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: conv.buyerName,
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              CustomText(
                text: conv.isOnline ? 'Online' : 'Last seen recently',
                fontSize: AppFontSize.tiny,
                color: AppColors.white.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined,
              color: AppColors.white, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined,
              color: AppColors.white, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final String initials;
  final bool isOnline;
  const _HeaderAvatar({required this.initials, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.25),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white.withOpacity(0.5), width: 1.5),
          ),
          alignment: Alignment.center,
          child: CustomText(
            text: initials,
            fontSize: AppFontSize.verySmall,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: AppColors.greenSuccess,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Message list (reverse: true → newest at bottom) ───────────────────────────

class _MessageList extends StatelessWidget {
  final SellerChatController controller;
  const _MessageList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msgs = controller.messages;
      if (msgs.isEmpty) {
        return const Center(
          child: CustomText(
            text: 'No messages yet. Say hello! 👋',
            fontSize: AppFontSize.verySmall,
            color: AppColors.grey,
          ),
        );
      }
      return ListView.builder(
        controller: controller.scrollCtrl,
        reverse: true,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        itemCount: msgs.length,
        itemBuilder: (_, i) {
          // reverse: true — index 0 = newest message (bottom)
          final msg = msgs[msgs.length - 1 - i];
          final isFirst = i == msgs.length - 1; // oldest message
          final showDate = isFirst ||
              msgs[msgs.length - i - 1].date !=
                  msgs[msgs.length - i - 2].date;

          return Column(
            children: [
              if (showDate) ChatDateSeparator(date: msg.date),
              ChatBubble(message: msg),
            ],
          );
        },
      );
    });
  }
}
