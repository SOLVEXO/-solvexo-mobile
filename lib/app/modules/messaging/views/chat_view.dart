import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/messaging/controllers/chat_controller.dart';
import 'package:book_store_app/app/modules/messaging/widgets/chat_input_bar.dart';
import 'package:book_store_app/app/modules/messaging/widgets/chat_shimmer.dart';
import 'package:book_store_app/app/modules/messaging/widgets/message_bubble.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatView extends StatelessWidget {
  ChatView({super.key});

  final ChatController c = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ChatAppBar(c: c),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) return const ChatShimmer();

              if (c.messages.isEmpty) {
                return const Center(
                  child: CustomText(
                    text: 'Say hello 👋',
                    fontSize: AppFontSize.small2,
                    color: AppColors.gray600,
                  ),
                );
              }

              // Newest-first for `reverse: true` — index 0 renders at the
              // bottom (visually "now"), matching normal chat apps.
              final displayList = c.messages.reversed.toList();

              return ListView.builder(
                controller: c.scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                itemCount: displayList.length + (c.hasOlder.value ? 1 : 0),
                itemBuilder: (_, i) {
                  if (c.hasOlder.value && i == displayList.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: c.isLoadingOlder.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryColor,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  final message = displayList[i];
                  return MessageBubble(
                    message: message,
                    isMine: message.isMine(c.myUserId),
                  );
                },
              );
            }),
          ),
          ChatInputBar(c: c),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatController c;
  const _ChatAppBar({required this.c});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.5,
      shadowColor: AppColors.black.withOpacity(0.06),
      leadingWidth: 44,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const SvgIcon(assetName: AppIcons.chevronLeft),
      ),
      titleSpacing: 0,
      title: Obx(() {
        final avatar = c.peerAvatar.value;
        final name =
            c.conversation.value?.peerName(c.myRole) ?? c.initialPeerName;
        final initials = name.trim().isNotEmpty
            ? name.trim()[0].toUpperCase()
            : '?';
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: avatar != null && avatar.isNotEmpty
                  ? CommonImageView(
                      url: avatar,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 38,
                      height: 38,
                      color: AppColors.primaryColor.withOpacity(0.1),
                      alignment: Alignment.center,
                      child: CustomText(
                        text: initials,
                        fontSize: AppFontSize.small2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomText(
                text: name,
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.w700,
                color: AppColors.black2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }),
      actions: [
        PopupMenuButton<String>(
          icon: const SvgIcon(
            assetName: AppIcons.menuImage,
            size: 25,
            color: AppColors.black2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (value) {
            if (value == 'block') _confirmBlock(context);
            if (value == 'report') _showReportSheet(context);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block_rounded, size: 18, color: AppColors.red),
                  SizedBox(width: 10),
                  CustomText(
                    text: 'Block',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  SvgIcon(
                    assetName: AppIcons.reportIcon,
                    size: 18,
                    color: AppColors.gray600,
                  ),
                  SizedBox(width: 10),
                  CustomText(
                    text: 'Report',
                    fontSize: AppFontSize.verySmall,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmBlock(BuildContext context) {
    CustomConfirmDialog.show(
      context,
      title: 'Block this conversation?',
      message:
          'You will no longer receive messages from them, and they won\'t be notified.',
      confirmLabel: 'Block',
      confirmColor: AppColors.red,
      onConfirm: c.blockPeer,
    );
  }

  void _showReportSheet(BuildContext context) {
    const reasons = {
      'spam': 'Spam',
      'harassment': 'Harassment',
      'inappropriate_content': 'Inappropriate content',
      'fraud': 'Fraud or scam',
      'other': 'Other',
    };
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const CustomText(
              text: 'Report this conversation',
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.bold,
              color: AppColors.black2,
            ),
            const SizedBox(height: 12),
            ...reasons.entries.map(
              (e) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: CustomText(
                  text: e.value,
                  fontSize: AppFontSize.verySmall,
                  color: AppColors.black2,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  c.reportConversation(e.key);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
