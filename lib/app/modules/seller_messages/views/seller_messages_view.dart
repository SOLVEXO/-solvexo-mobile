import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/shimmer/trip_shimmer.dart';
import 'package:book_store_app/app/modules/seller_messages/controllers/seller_messages_controller.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/conversation_tile.dart';
import 'package:book_store_app/app/modules/seller_messages/widgets/messages_empty_state.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerMessagesView extends StatelessWidget {
  SellerMessagesView({super.key});

  final SellerMessagesController controller = Get.put(
    SellerMessagesController(),
  );

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
          const Divider(height: 1, color: AppColors.lightGrey2),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return TripShimmer(itemCount: 5);
              }

              final convs = controller.filteredConversations;
              if (convs.isEmpty) return const MessagesEmptyState();

              return CustomRefreshWrapper(
                onRefresh: controller.refreshData,
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
                    onTap: () =>
                        Get.toNamed(Routes.sellerChat, arguments: convs[i]),
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
