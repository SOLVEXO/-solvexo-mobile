import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/modules/messaging/widgets/conversations_shimmer.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/conversation_tile.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/messages_empty_state.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerMessagesView extends StatelessWidget {
  SellerMessagesView({super.key});

  final SellerMessagesController controller = Get.put(SellerMessagesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(
        title: "Messages",
        backgroundColor: AppColors.primaryColor,
        color: AppColors.white,
      ),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _SearchBar(controller: controller),
          _FilterTabs(controller: controller),
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ConversationsShimmer();
              }

              final convs = controller.filteredConversations;
              if (convs.isEmpty) return const MessagesEmptyState();

              return CustomRefreshWrapper(
                onRefresh: controller.loadConversations,
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 4, bottom: 16),
                  itemCount: convs.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 78,
                    color: AppColors.lightGrey2,
                  ),
                  itemBuilder: (_, i) => ConversationTile(
                    conversation: convs[i],
                    controller: controller,
                    onTap: () => controller.openChat(convs[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final SellerMessagesController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: 8,
      ),
      child: CustomTextField(
        onChanged: controller.onSearch,
        hintText: 'Search conversations...',
        isborder: true,
        fillColor: AppColors.background,
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.grey,
          size: 20,
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final SellerMessagesController controller;
  const _FilterTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(AppDimen.allPadding, 0, AppDimen.allPadding, 10),
      child: Obx(
        () => Row(
          children: [
            _Tab(
              label: 'Active',
              selected: controller.filter.value == InboxFilter.active,
              onTap: () => controller.setFilter(InboxFilter.active),
            ),
            const SizedBox(width: 8),
            _Tab(
              label: 'Archived',
              selected: controller.filter.value == InboxFilter.archived,
              onTap: () => controller.setFilter(InboxFilter.archived),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomText(
          text: label,
          fontSize: AppFontSize.tiny,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.white : AppColors.gray600,
        ),
      ),
    );
  }
}
