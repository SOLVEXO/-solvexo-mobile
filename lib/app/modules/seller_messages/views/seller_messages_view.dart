import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/messaging/widgets/conversations_shimmer.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/conversation_tile.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/messages_empty_state.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerMessagesView extends StatelessWidget {
  SellerMessagesView({super.key});

  final SellerMessagesController controller = Get.put(SellerMessagesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBarTwo(title: "Messages"),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _SearchBar(controller: controller),
          _FilterTabs(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const ConversationsShimmer();
              }

              final convs = controller.filteredConversations;
              if (convs.isEmpty) {
                return MessagesEmptyState(isArchived: controller.filter.value == InboxFilter.archived);
              }

              return CustomRefreshWrapper(
                onRefresh: controller.loadConversations,
                child: ListView.separated(
                  padding: EdgeInsets.only(bottom: BaseSpacing.md),
                  itemCount: convs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.lightGrey3),
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
      padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.sm, BaseSpacing.md, BaseSpacing.sm),
      child: CustomTextField(
        onChanged: controller.onSearch,
        hintText: 'Search conversations',
        isborder: true,
        fillColor: AppColors.textfldFillColor,
        borderRadius: BorderRadius.circular(BaseRadius.md),
        borderBorderradius: BaseRadius.md,
        prefixIcon: SvgIcon(assetName: AppIcons.searchIcon, size: 20, color: AppColors.iosGrey),
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
      padding: EdgeInsets.fromLTRB(BaseSpacing.md, 0, BaseSpacing.md, BaseSpacing.sm),
      child: Obx(
        () => Row(
          children: [
            _Tab(
              label: 'Active',
              selected: controller.filter.value == InboxFilter.active,
              onTap: () => controller.setFilter(InboxFilter.active),
            ),
            SizedBox(width: BaseSpacing.xs),
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
        duration: BaseMotion.normal,
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.lightGrey10,
          borderRadius: BorderRadius.circular(BaseRadius.pill),
        ),
        child: Text(
          label,
          style: BaseTypography.labelSmall(
            color: selected ? AppColors.white : AppColors.gray600,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
