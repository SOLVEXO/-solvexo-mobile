import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class ConversationTile extends StatelessWidget {
  final SellerConversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primaryColor.withOpacity(0.05),
      highlightColor: AppColors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Avatar(
              initials: conversation.buyerInitials,
              isOnline: conversation.isOnline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: conversation.buyerName,
                          fontSize: AppFontSize.small2,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                      CustomText(
                        text: conversation.lastMessageTime,
                        fontSize: AppFontSize.tiny,
                        color: conversation.unreadCount > 0
                            ? AppColors.primaryColor
                            : AppColors.grey,
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (conversation.lastFromSeller) ...[
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: AppColors.iosBlue,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Expanded(
                        child: CustomText(
                          text: conversation.lastMessage,
                          fontSize: AppFontSize.verySmall,
                          color: conversation.unreadCount > 0
                              ? AppColors.black2
                              : AppColors.grey,
                          fontWeight: conversation.unreadCount > 0
                              ? FontWeight.w500
                              : FontWeight.w400,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        _UnreadBadge(count: conversation.unreadCount),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar with online indicator ──────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final bool isOnline;

  const _Avatar({required this.initials, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: CustomText(
            text: initials,
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: AppColors.greenSuccess,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Unread count badge ────────────────────────────────────────────────────────

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomText(
        text: count > 9 ? '9+' : '$count',
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
      ),
    );
  }
}
