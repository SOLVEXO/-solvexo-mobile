import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_finance/controllers/seller_finance_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinanceTransactionList extends StatelessWidget {
  final SellerFinanceController controller;
  const FinanceTransactionList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(controller: controller),
          const SizedBox(height: 10),
          _FilterChips(controller: controller),
          const SizedBox(height: 12),
          Obx(() {
            final list = controller.filteredTransactions;
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGrey11),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 36, color: AppColors.lightGrey5),
                      SizedBox(height: 8),
                      CustomText(
                        text: 'No transactions found',
                        color: AppColors.lightGrey5,
                        fontSize: AppFontSize.small2,
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: List.generate(list.length, (i) {
                return _TransactionCard(tx: list[i]);
              }),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final SellerFinanceController controller;
  const _SectionHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: CustomText(
            text: 'Transactions',
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w700,
            color: AppColors.black2,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.download_rounded,
                    size: 13, color: AppColors.primaryColor),
                SizedBox(width: 5),
                CustomText(
                  text: 'Export',
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final SellerFinanceController controller;
  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: controller.filters.map((f) {
              final active = controller.activeFilter.value == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.setFilter(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryColor
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active
                            ? AppColors.primaryColor
                            : AppColors.lightGrey11,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primaryColor.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: CustomText(
                      text: f,
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.white : AppColors.lightGrey5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

class _TransactionCard extends StatelessWidget {
  final FinanceTransaction tx;
  const _TransactionCard({required this.tx});

  IconData get _icon {
    switch (tx.type) {
      case TransactionType.sale:    return Icons.arrow_downward_rounded;
      case TransactionType.payout:  return Icons.arrow_upward_rounded;
      case TransactionType.fee:     return Icons.percent_rounded;
      case TransactionType.refund:  return Icons.keyboard_return_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey11),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tx.type.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, size: 18, color: tx.type.color),
          ),
          const SizedBox(width: 12),
          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: tx.description,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _TypePill(type: tx.type),
                    const SizedBox(width: 8),
                    CustomText(
                      text: tx.date,
                      fontSize: AppFontSize.tiny,
                      color: AppColors.lightGrey5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Amount + balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: tx.formattedAmount,
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.w700,
                color: tx.type.isPositive
                    ? AppColors.darkGreen
                    : const Color(0xFFDC2626),
              ),
              const SizedBox(height: 3),
              CustomText(
                text: '\$${tx.balance.toStringAsFixed(2)}',
                fontSize: AppFontSize.tiny,
                color: AppColors.lightGrey5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final TransactionType type;
  const _TypePill({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: type.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: type.color,
        ),
      ),
    );
  }
}
