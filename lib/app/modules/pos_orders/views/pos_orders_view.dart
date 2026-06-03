import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_orders/controllers/pos_orders_controller.dart';
import 'package:book_store_app/app/modules/pos_orders/widgets/pos_stats_row.dart';
import 'package:book_store_app/app/modules/pos_orders/widgets/pos_transaction_card.dart';
import 'package:book_store_app/app/modules/pos_orders/widgets/pos_transactions_empty.dart';
import 'package:book_store_app/app/modules/pos_orders/widgets/pos_transactions_shimmer.dart';
import 'package:book_store_app/app/modules/pos/widgets/pos_app_bar.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosOrdersView extends StatelessWidget {
  PosOrdersView({super.key});

  final PosOrdersController controller = Get.put(PosOrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const PosAppBar(title: 'Transactions', subtitle: 'EduDeen POS'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const PosTransactionsShimmer();
              }
              final txns = controller.transactions;
              if (txns.isEmpty) return const PosTransactionsEmpty();
              return CustomRefreshWrapper(
                onRefresh: controller.refreshData,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateFilterHeader(controller: controller),
                      PosStatsRow(controller: controller),
                      const Divider(height: 1, color: AppColors.lightGrey2),
                      ListView.separated(
                        padding: const EdgeInsets.all(AppDimen.allPadding),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: txns.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            PosTransactionCard(transaction: txns[i]),
                      ),
                    ],
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

class _DateFilterHeader extends StatelessWidget {
  final PosOrdersController controller;

  const _DateFilterHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimen.allPadding,
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText(
            text: 'Transactions',
            fontSize: AppFontSize.medium,
            fontWeight: FontWeight.bold,
            color: AppColors.black2,
          ),
          Obx(
            () => GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimen.draggableBorderRadius,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: controller.dateFilter.value,
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
