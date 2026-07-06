import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/components/unread_count_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A single row in the buyer's inbox — shows the store's avatar/name, the
/// last-message preview, a relative timestamp, and an unread-count badge.
class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;

  const ConversationTile({super.key, required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadFor('user');
    final name = conversation.peerName('user');
    final avatar = conversation.peerAvatar('user');
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppColors.white,
        child: Row(
          children: [
            UnreadCountBadge(
              count: unread,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: avatar != null && avatar.isNotEmpty
                    ? CommonImageView(url: avatar, width: 52, height: 52, fit: BoxFit.cover)
                    : Container(
                        width: 52,
                        height: 52,
                        color: AppColors.primaryColor.withOpacity(0.1),
                        alignment: Alignment.center,
                        child: CustomText(
                          text: initials,
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: name,
                    fontSize: AppFontSize.verySmall,
                    fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.black2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  CustomText(
                    text: conversation.lastMessage?.previewText ?? 'Start the conversation',
                    fontSize: AppFontSize.tiny,
                    fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                    color: unread > 0 ? AppColors.black2 : AppColors.gray600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CustomText(
              text: _relativeTime(conversation.updatedAt),
              fontSize: AppFontSize.tiny,
              color: unread > 0 ? AppColors.primaryColor : AppColors.gray600,
              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inHours < 24 && now.day == local.day) return DateFormat('h:mm a').format(local);
    if (diff.inDays < 7) return DateFormat('EEE').format(local);
    return DateFormat('MMM d').format(local);
  }
}
