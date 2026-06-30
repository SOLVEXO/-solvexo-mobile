import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_status_badge.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_status_picker_sheet.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_type_badge.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderCard extends StatelessWidget {
  final SellerOrder order;
  final SellerOrdersController controller;

  const OrderCard({super.key, required this.order, required this.controller});

  bool get _isCompleted =>
      order.status == OrderStatus.completed ||
      order.status == OrderStatus.refunded;

  // COD + unpaid + still active → show both Mark as Paid and View Details
  bool get _showMarkAsPaid => order.canMarkPaid;

  // Non-COD active orders → show Fulfill + View
  bool get _showActions =>
      !_isCompleted &&
      !_showMarkAsPaid &&
      (order.status == OrderStatus.pending ||
          order.status == OrderStatus.processing ||
          order.status == OrderStatus.shipped);

  void _openDetail() =>
      Get.toNamed(Routes.sellerOrderDetail, arguments: order);

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
          _itemsList(),
          const SizedBox(height: 6),
          _metaRow(),
          const SizedBox(height: 4),
          _dateRow(),
          if (_isCompleted) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.lightGrey2),
            const SizedBox(height: 12),
            _ViewButton(onTap: _openDetail),
          ] else if (_showMarkAsPaid) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.lightGrey2),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MarkAsPaidButton(
                    order: order,
                    controller: controller,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ViewButton(onTap: _openDetail),
                ),
              ],
            ),
          ] else if (_showActions) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.lightGrey2),
            const SizedBox(height: 12),
            if (order.isPhysical)
              Row(
                children: [
                  Expanded(
                    child: _UpdateStatusButton(
                      order: order,
                      controller: controller,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _ViewButton(onTap: _openDetail)),
                ],
              )
            else
              _ViewButton(onTap: _openDetail),
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
          text: order.orderNumber,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          overflow: TextOverflow.ellipsis,
        ),
        OrderStatusBadge(status: order.status),
      ],
    );
  }

  Widget _itemsList() {
    final items = order.items;
    if (items.isEmpty) {
      return CustomText(
        text: order.primaryProductName,
        fontSize: AppFontSize.small2,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    const maxVisible = 2;
    final visible = items.take(maxVisible).toList();
    final extra = items.length - maxVisible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visible.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    text: item.productName,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 6),
                CustomText(
                  text: 'x${item.quantity}',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.lightGrey5,
                ),
              ],
            ),
          ),
        ),
        if (extra > 0)
          CustomText(
            text: '+$extra more item${extra > 1 ? 's' : ''}',
            fontSize: AppFontSize.tiny,
            color: AppColors.primaryColor,
          ),
      ],
    );
  }

  Widget _metaRow() {
    return Row(
      children: [
        CustomText(
          text: '${order.customerName} · ',
          fontSize: AppFontSize.verySmall,
          color: AppColors.grey,
        ),
        OrderTypeBadge(type: order.primaryType),
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

// ── Update Status button (physical active orders) ────────────────────────────

class _UpdateStatusButton extends StatelessWidget {
  final SellerOrder order;
  final SellerOrdersController controller;

  const _UpdateStatusButton({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => OrderStatusPickerSheet.show(order, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_vert_rounded, size: 15, color: AppColors.primaryColor),
            SizedBox(width: 6),
            CustomText(
              text: 'Update Status',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── View button (completed / refunded orders) ─────────────────────────────────

class _ViewButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_outlined,
                size: 15, color: AppColors.primaryColor),
            SizedBox(width: 6),
            CustomText(
              text: 'View Order',
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mark as Paid button ───────────────────────────────────────────────────────

class _MarkAsPaidButton extends StatelessWidget {
  final SellerOrder order;
  final SellerOrdersController controller;

  const _MarkAsPaidButton({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isMarkingPaid(order.id);
      return GestureDetector(
        onTap: isLoading ? null : () => controller.markOrderPaid(order.id),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.darkGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
            border: Border.all(color: AppColors.darkGreen.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.darkGreen,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments_outlined,
                        size: 15, color: AppColors.darkGreen),
                    SizedBox(width: 6),
                    CustomText(
                      text: 'Mark as Paid',
                      fontSize: AppFontSize.verySmall,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
