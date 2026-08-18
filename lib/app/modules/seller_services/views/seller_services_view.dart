import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_services/controllers/seller_services_controller.dart';
import 'package:book_store_app/app/modules/seller_services/widgets/services_bookings_tab.dart';
import 'package:book_store_app/app/modules/seller_services/widgets/services_dashboard_tab.dart';
import 'package:book_store_app/app/modules/seller_services/widgets/services_list_tab.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerServicesView extends StatelessWidget {
  SellerServicesView({super.key});

  final SellerServicesController controller = Get.put(SellerServicesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBarTwo(title: 'Services & Bookings'),
      body: Column(
        children: [
          _TabBar(controller: controller),
          Expanded(
            child: Obx(() {
              return switch (controller.tab.value) {
                ServicesTab.dashboard => ServicesDashboardTab(controller: controller),
                ServicesTab.services => ServicesListTab(controller: controller),
                ServicesTab.bookings => ServicesBookingsTab(controller: controller),
              };
            }),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final SellerServicesController controller;
  const _TabBar({required this.controller});

  static const _tabs = [
    (ServicesTab.dashboard, 'Dashboard'),
    (ServicesTab.services, 'Services'),
    (ServicesTab.bookings, 'Bookings'),
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
