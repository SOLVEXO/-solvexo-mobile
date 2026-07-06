import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/models/messaging/message_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;

  const MessageBubble({super.key, required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.74),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildContent(context),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: message.createdAt != null ? DateFormat('h:mm a').format(message.createdAt!.toLocal()) : '',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.gray600,
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(_statusIcon, size: 13, color: _statusColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData get _statusIcon => message.status == 'sent' ? Icons.check_rounded : Icons.done_all_rounded;
  Color get _statusColor => message.status == 'seen' ? AppColors.primaryColor : AppColors.gray600;

  Widget _buildContent(BuildContext context) {
    if (message.isDeleted) {
      return _bubbleWrapper(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block_rounded, size: 14, color: isMine ? AppColors.white.withOpacity(0.7) : AppColors.gray600),
            const SizedBox(width: 6),
            CustomText(
              text: 'This message was deleted',
              fontSize: AppFontSize.verySmall,
              fontStyle: FontStyle.italic,
              color: isMine ? AppColors.white.withOpacity(0.7) : AppColors.gray600,
            ),
          ],
        ),
      );
    }

    switch (message.type) {
      case 'image':
        return _imageBubble(context);
      case 'product_share':
        return _productShareBubble();
      default:
        return _bubbleWrapper(
          CustomText(
            text: message.text ?? '',
            fontSize: AppFontSize.verySmall,
            color: isMine ? AppColors.white : AppColors.black2,
          ),
        );
    }
  }

  Widget _bubbleWrapper(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: isMine
            ? const LinearGradient(colors: [AppColors.primaryColor, AppColors.accentColor])
            : null,
        color: isMine ? null : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        boxShadow: isMine
            ? null
            : [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _imageBubble(BuildContext context) {
    final url = message.attachments.isNotEmpty ? message.attachments.first.url : null;
    return GestureDetector(
      onTap: url == null ? null : () => _openFullImage(context, url),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        child: url != null
            ? CommonImageView(url: url, width: 200, height: 220, fit: BoxFit.cover)
            : _bubbleWrapper(const CustomText(text: 'Photo', fontSize: AppFontSize.verySmall)),
      ),
    );
  }

  void _openFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: AppColors.black.withOpacity(0.9),
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: CommonImageView(url: url, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.black.withOpacity(0.4), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const SvgIcon(assetName: AppIcons.cross, color: AppColors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productShareBubble() {
    final p = message.productShare;
    if (p == null) return _bubbleWrapper(const CustomText(text: 'Shared a product', fontSize: AppFontSize.verySmall));

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.productDetailsView, arguments: p.productId),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CommonImageView(url: p.image ?? '', height: 110, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            CustomText(
              text: p.title,
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.black2,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            CustomText(
              text: '\$${p.price.toStringAsFixed(2)}',
              fontSize: AppFontSize.small2,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
