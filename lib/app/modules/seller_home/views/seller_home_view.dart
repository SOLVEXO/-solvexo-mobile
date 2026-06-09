import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/custom_low_stock_alert.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/custom_recent_orders.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/seller_messages_section.dart';
import 'package:book_store_app/app/modules/seller/widgets/seller_app_bar.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/seller_home_shimmer.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/seller_quick_actions.dart';
import 'package:book_store_app/app/modules/seller_home/widgets/seller_status_card.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerHomeView extends StatelessWidget {
  final controller = Get.put(SellerHomeController());

  SellerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SellerAppBar(),
          Expanded(
            child: CustomRefreshWrapper(
              onRefresh: () => controller.refreshData(),
              child: SingleChildScrollView(
                child: Obx(
                  () => controller.isLoading.value
                      ? const SellerHomeShimmer()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SellerStatusCard(),
                            const Divider(
                              height: 1,
                              color: AppColors.lightGrey2,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  _sectionHeader('Quick Actions'),
                                  const SizedBox(height: 10),
                                  SellerQuickActions(),
                                  const SizedBox(height: 16),
                                  CustomLowStockAlert(),
                                  const SizedBox(height: 16),
                                  _buildRecentOrdersHeader(),
                                  CustomRecentOrders(),
                                  const SizedBox(height: 16),
                                  SellerMessagesSection(),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomText(text: title, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecentOrdersHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText(
            text: 'Recent Orders',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          TextButton(
            onPressed: () => Get.toNamed(Routes.sellerOrders),
            child: CustomText(
              text: 'View all →',
              fontSize: 13,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
