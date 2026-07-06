import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/messaging/conversation_model.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SellerMessagesSection extends StatelessWidget {
  SellerMessagesSection({super.key});

  final SellerHomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final convs = controller.recentConversations;
      if (convs.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: convs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MessageCard(conversation: convs[i]),
          ),
        ],
      );
    });
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText(
            text: 'Messages',
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.bold,
          ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.sellerMessages),
            child: CustomText(
              text: 'View all →',
              fontSize: AppFontSize.verySmall,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final ConversationModel conversation;

  const _MessageCard({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final name = conversation.peerName('seller');
    final avatar = conversation.peerAvatar('seller');
    final unread = conversation.unreadFor('seller') > 0;
    final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.chatView, arguments: {
        'conversationId': conversation.id,
        'peerName': name,
        'peerAvatar': avatar,
      }),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(initials: initials, avatarUrl: avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: name,
                          fontSize: AppFontSize.small2,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CustomText(
                        text: _relativeTime(conversation.updatedAt),
                        fontSize: AppFontSize.tiny,
                        color: AppColors.grey,
                      ),
                      if (unread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: conversation.lastMessage?.previewText ?? 'Start the conversation',
                    fontSize: AppFontSize.verySmall,
                    color: AppColors.grey,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && now.day == local.day) return DateFormat('h:mm a').format(local);
    if (diff.inDays < 7) return DateFormat('EEE').format(local);
    return DateFormat('MMM d').format(local);
  }
}

class _Avatar extends StatelessWidget {
  final String initials;
  final String? avatarUrl;

  const _Avatar({required this.initials, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? CommonImageView(url: avatarUrl!, width: 44, height: 44, fit: BoxFit.cover)
          : Container(
              width: 44,
              height: 44,
              color: AppColors.primaryColor.withOpacity(0.12),
              alignment: Alignment.center,
              child: CustomText(
                text: initials,
                fontSize: AppFontSize.extraSmall,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
    );
  }
}
