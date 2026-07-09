import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/unread_count_badge.dart';
import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Mirrors the buyer-side `ConversationTile` visually (same avatar/badge,
/// typography, spacing tokens) but keeps the seller-only inbox management —
/// pin/mute indicators and a long-press actions sheet for
/// pin/mute/archive/delete.
class ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final SellerMessagesController controller;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadFor('seller');
    final name = conversation.peerName('seller');
    final avatar = conversation.peerAvatar('seller');
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showActionsSheet(context),
      splashColor: AppColors.primaryColor.withOpacity(0.05),
      highlightColor: AppColors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md - 1, vertical: BaseSpacing.sm),
        color: AppColors.white,
        child: Row(
          children: [
            UnreadCountBadge(
              count: unread,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BaseRadius.xxxl - 6),
                child: avatar != null && avatar.isNotEmpty
                    ? CommonImageView(url: avatar, width: 52, height: 52, fit: BoxFit.cover)
                    : Container(
                        width: 52,
                        height: 52,
                        color: AppColors.primaryColor.withOpacity(0.1),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: BaseTypography.bodyMedium(color: AppColors.primaryColor).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (conversation.isPinned) ...[
                        const Icon(Icons.push_pin_rounded, size: 13, color: AppColors.gray600),
                        SizedBox(width: BaseSpacing.xxs),
                      ],
                      Expanded(
                        child: Text(
                          name,
                          style: BaseTypography.labelSmall(color: AppColors.black2).copyWith(
                            fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: BaseSpacing.xs),
                      Text(
                        _relativeTime(conversation.updatedAt),
                        style: BaseTypography.labelSmall(
                          color: unread > 0 ? AppColors.primaryColor : AppColors.gray600,
                        ).copyWith(fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400),
                      ),
                    ],
                  ),
                  SizedBox(height: BaseSpacing.xxs - 1),
                  Row(
                    children: [
                      if (conversation.isMuted) ...[
                        const Icon(Icons.volume_off_rounded, size: 13, color: AppColors.gray600),
                        SizedBox(width: BaseSpacing.xxs),
                      ],
                      Expanded(
                        child: Text(
                          conversation.lastMessage?.previewText ?? 'No messages yet',
                          style: BaseTypography.labelSmall(
                            color: unread > 0 ? AppColors.black2 : AppColors.gray600,
                          ).copyWith(fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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

  void _showActionsSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(BaseRadius.xxl)),
        ),
        padding: EdgeInsets.fromLTRB(0, BaseSpacing.sm, 0, MediaQuery.of(context).padding.bottom + BaseSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: BaseSpacing.sm),
              decoration: BoxDecoration(color: AppColors.lightGrey2, borderRadius: BorderRadius.circular(BaseRadius.xs / 2)),
            ),
            const Divider(height: 1, color: AppColors.lightGrey2),
            _ActionRow(
              icon: conversation.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: conversation.isPinned ? 'Unpin' : 'Pin to top',
              onTap: () {
                Get.back();
                controller.togglePin(conversation);
              },
            ),
            _ActionRow(
              icon: conversation.isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              label: conversation.isMuted ? 'Unmute' : 'Mute',
              onTap: () {
                Get.back();
                controller.toggleMute(conversation);
              },
            ),
            _ActionRow(
              icon: conversation.isArchived ? Icons.unarchive_rounded : Icons.archive_outlined,
              label: conversation.isArchived ? 'Restore to inbox' : 'Archive',
              onTap: () {
                Get.back();
                controller.toggleArchive(conversation);
              },
            ),
            _ActionRow(
              icon: Icons.delete_outline_rounded,
              label: 'Delete conversation',
              danger: true,
              onTap: () {
                Get.back();
                controller.deleteConversation(conversation);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _ActionRow({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.red : AppColors.primaryColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.lg, vertical: BaseSpacing.sm + 1),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(BaseRadius.md)),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: color),
            ),
            SizedBox(width: BaseSpacing.sm + 2),
            Text(
              label,
              style: BaseTypography.bodySmall(
                color: danger ? AppColors.red : AppColors.black2,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
