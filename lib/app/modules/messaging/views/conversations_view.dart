import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/messaging/controllers/conversations_controller.dart';
import 'package:book_store_app/app/modules/messaging/widgets/conversation_tile.dart';
import 'package:book_store_app/app/modules/messaging/widgets/conversations_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConversationsView extends StatelessWidget {
  ConversationsView({super.key});

  final ConversationsController c = Get.put(ConversationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Messages'),
      body: Obx(() {
        if (c.isLoading.value) return const ConversationsShimmer();

        if (c.conversations.isEmpty) return const _EmptyInbox();

        return CustomRefreshWrapper(
          onRefresh: c.loadConversations,
          child: ListView.separated(
            itemCount: c.conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.lightGrey3),
            itemBuilder: (_, i) {
              final conv = c.conversations[i];
              return ConversationTile(conversation: conv, onTap: () => c.openChat(conv));
            },
          ),
        );
      }),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor.withOpacity(0.12), AppColors.accentColor.withOpacity(0.06)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: const SvgIcon(assetName: AppIcons.messageIcon, size: 34, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          const CustomText(
            text: 'No messages yet',
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.bold,
            color: AppColors.black2,
          ),
          const SizedBox(height: 6),
          const CustomText(
            text: 'Messages with sellers you contact\nwill show up here.',
            fontSize: AppFontSize.verySmall,
            color: AppColors.gray600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
