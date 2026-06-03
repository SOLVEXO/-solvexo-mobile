import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_orders/controllers/pos_orders_controller.dart';
import 'package:book_store_app/app/modules/pos_orders/widgets/pos_payment_badge.dart';
import 'package:book_store_app/app/modules/pos_orders/widgets/pos_transaction_buttons.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class PosTransactionCard extends StatelessWidget {
  final PosTransaction transaction;

  const PosTransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimen.allPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _topRow(),
          const SizedBox(height: 8),
          _metaRow(),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.lightGrey2),
          const SizedBox(height: 12),
          PosTransactionButtons(
            onReceipt: () {},
            onRefund: () {},
          ),
        ],
      ),
    );
  }

  Widget _topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: transaction.id,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        CustomText(
          text: '\$${transaction.amount.toStringAsFixed(2)}',
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ],
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        CustomText(
          text: transaction.customer,
          fontSize: AppFontSize.verySmall,
          color: AppColors.grey,
        ),
        const SizedBox(width: 8),
        PosPaymentBadge(method: transaction.paymentMethod),
        const Spacer(),
        CustomText(
          text: transaction.time,
          fontSize: AppFontSize.verySmall,
          color: AppColors.lightGrey5,
        ),
      ],
    );
  }
}
