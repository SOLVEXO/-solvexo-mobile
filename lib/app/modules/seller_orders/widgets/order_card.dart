import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_action_buttons.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_status_badge.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_type_badge.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final SellerOrder order;

  const OrderCard({super.key, required this.order});

  bool get _showActions =>
      order.status == OrderStatus.pending ||
      order.status == OrderStatus.processing;

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
          _productName(),
          const SizedBox(height: 6),
          _metaRow(),
          const SizedBox(height: 4),
          _dateRow(),
          if (_showActions) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.lightGrey2),
            const SizedBox(height: 12),
            OrderActionButtons(onFulfill: () {}, onView: () {}),
          ],
        ],
      ),
    );
  }

  Widget _topRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: order.id,
          fontSize: AppFontSize.small2,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        OrderStatusBadge(status: order.status),
      ],
    );
  }

  Widget _productName() {
    return CustomText(
      text: order.productName,
      fontSize: AppFontSize.small2,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        CustomText(
          text: '${order.customer} · ',
          fontSize: AppFontSize.verySmall,
          color: AppColors.grey,
        ),
        OrderTypeBadge(type: order.type),
        const Spacer(),
        CustomText(
          text: '\$${order.amount.toStringAsFixed(2)}',
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ],
    );
  }

  Widget _dateRow() {
    return CustomText(
      text: order.date,
      fontSize: AppFontSize.tiny,
      color: AppColors.lightGrey5,
    );
  }
}
