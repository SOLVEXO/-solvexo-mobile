import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_balance_card.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_payout_schedule.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_shimmer.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_stats_row.dart';
import 'package:book_store_app/app/modules/seller_finance/widgets/finance_transaction_list.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerFinanceView extends StatelessWidget {
  SellerFinanceView({super.key});

  final SellerFinanceController controller = Get.put(SellerFinanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomAppBarTwo(title: 'Finance & Payouts'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const FinanceShimmer();
              }
              return CustomRefreshWrapper(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.only(top: 16, bottom: 30),
                  children: [
                    FinanceBalanceCard(controller: controller),
                    const SizedBox(height: 12),
                    FinanceStatsRow(controller: controller),
                    const SizedBox(height: 12),
                    FinanceTransactionList(controller: controller),
                    const SizedBox(height: 12),
                    FinancePayoutSchedule(controller: controller),
                    const SizedBox(height: 12),
                    FinanceFeeBreakdown(controller: controller),
                    const SizedBox(height: 12),
                    FinanceTaxReports(controller: controller),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
