import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/modules/seller_loyalty/controllers/seller_loyalty_controller.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_members_tab.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_overview_tab.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_program_tab.dart';
import 'package:book_store_app/app/modules/seller_loyalty/widgets/loyalty_rewards_tab.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerLoyaltyView extends StatelessWidget {
  SellerLoyaltyView({super.key});

  final SellerLoyaltyController controller = Get.put(SellerLoyaltyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Loyalty & Rewards'),
      body: Column(
        children: [
          _TabBar(controller: controller),
          Expanded(
            child: Obx(() {
              return switch (controller.tab.value) {
                LoyaltyTab.overview => LoyaltyOverviewTab(controller: controller),
                LoyaltyTab.program => LoyaltyProgramTab(controller: controller),
                LoyaltyTab.members => LoyaltyMembersTab(controller: controller),
                LoyaltyTab.rewards => LoyaltyRewardsTab(controller: controller),
              };
            }),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final SellerLoyaltyController controller;
  const _TabBar({required this.controller});

  static const _tabs = [
    (LoyaltyTab.overview, 'Overview'),
    (LoyaltyTab.program, 'Program'),
    (LoyaltyTab.members, 'Members'),
    (LoyaltyTab.rewards, 'Rewards'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.sm),
      child: Obx(
        () => Row(
          children: _tabs.map((t) {
            final selected = controller.tab.value == t.$1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xxs),
                child: GestureDetector(
                  onTap: () => controller.changeTab(t.$1),
                  child: AnimatedContainer(
                    duration: BaseMotion.normal,
                    padding: EdgeInsets.symmetric(vertical: BaseSpacing.xs + 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryColor : AppColors.lightGrey10,
                      borderRadius: BorderRadius.circular(BaseRadius.pill),
                    ),
                    child: Text(
                      t.$2,
                      style: BaseTypography.labelSmall(color: selected ? AppColors.white : AppColors.gray600).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
