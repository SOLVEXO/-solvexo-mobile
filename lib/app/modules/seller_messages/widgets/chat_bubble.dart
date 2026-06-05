import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isSeller = message.isSeller;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isSeller ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSeller) ...[
            _BubbleAvatar(),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSeller
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSeller
                        ? AppColors.primaryColor
                        : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isSeller ? 18 : 2),
                      bottomRight: Radius.circular(isSeller ? 2 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomText(
                    text: message.text,
                    fontSize: AppFontSize.verySmall,
                    color: isSeller ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                _TimeRow(message: message),
              ],
            ),
          ),
          if (isSeller) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Buyer avatar (small, in chat) ─────────────────────────────────────────────

class _BubbleAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, size: 16, color: AppColors.primaryColor),
    );
  }
}

// ── Time + read receipt ───────────────────────────────────────────────────────

class _TimeRow extends StatelessWidget {
  final ChatMessage message;
  const _TimeRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: message.time,
          fontSize: 10,
          color: AppColors.lightGrey5,
        ),
        if (message.isSeller) ...[
          const SizedBox(width: 4),
          Icon(
            message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
            size: 14,
            color: message.isRead ? AppColors.iosBlue : AppColors.lightGrey5,
          ),
        ],
      ],
    );
  }
}

// ── Date separator ────────────────────────────────────────────────────────────

class ChatDateSeparator extends StatelessWidget {
  final String date;
  const ChatDateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.lightGrey2, height: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGrey2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomText(
              text: date,
              fontSize: 10,
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(child: Divider(color: AppColors.lightGrey2, height: 1)),
        ],
      ),
    );
  }
}
