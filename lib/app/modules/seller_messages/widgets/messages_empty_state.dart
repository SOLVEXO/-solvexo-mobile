import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class MessagesEmptyState extends StatelessWidget {
  const MessagesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimen.allPadding + 4),
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 52,
              color: AppColors.lightGrey,
            ),
          ),
          const SizedBox(height: 16),
          const CustomText(
            text: 'No messages yet',
            fontSize: AppFontSize.small2,
            fontWeight: FontWeight.w600,
            color: AppColors.black2,
          ),
          const SizedBox(height: 6),
          const CustomText(
            text: 'Buyer messages will appear here',
            fontSize: AppFontSize.verySmall,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
