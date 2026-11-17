import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/controllers/seller_subscriptions_controller.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/widgets/subscribers_tab.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/widgets/subscription_plans_tab.dart';
import 'package:book_store_app/app/modules/seller_subscriptions/widgets/subscriptions_dashboard_tab.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerSubscriptionsView extends StatelessWidget {
  SellerSubscriptionsView({super.key});

  final SellerSubscriptionsController controller = Get.put(SellerSubscriptionsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Subscription Plans'),
      body: Column(
        children: [
          _TabBar(controller: controller),
          Expanded(
            child: Obx(() {
              return switch (controller.tab.value) {
                SubscriptionsTab.dashboard => SubscriptionsDashboardTab(controller: controller),
                SubscriptionsTab.plans => SubscriptionPlansTab(controller: controller),
                SubscriptionsTab.subscribers => SubscribersTab(controller: controller),
              };
            }),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final SellerSubscriptionsController controller;
  const _TabBar({required this.controller});

  static const _tabs = [
    (SubscriptionsTab.dashboard, 'Dashboard'),
    (SubscriptionsTab.plans, 'Plans'),
    (SubscriptionsTab.subscribers, 'Subscribers'),
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
                    child: CustomText(
                      text: t.$2,
                      color: selected ? AppColors.white : AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
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
