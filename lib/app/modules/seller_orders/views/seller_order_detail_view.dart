import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_order_detail_controller.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_status_badge.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_status_picker_sheet.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/order_type_badge.dart';
import 'package:book_store_app/app/modules/seller_orders/widgets/seller_order_detail_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerOrderDetailView extends StatelessWidget {
  const SellerOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SellerOrderDetailController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(
        backgroundColor: AppColors.white,
        title: 'Order Detail',
        child: Obx(
          () => CustomText(
            text: ctrl.order.value.orderNumber,
            fontSize: AppFontSize.tiny,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomRefreshWrapper(
        onRefresh: ctrl.refreshOrder,
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const SellerOrderDetailShimmer();
          }
          final order = ctrl.order.value;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimen.allPadding),
            child: Column(
              children: [
                _StatusCard(order: order),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Customer',
                  icon: AppIcons.profileIcon,
                  rows: [
                    _Row('Name', order.customerName),
                    _Row('Email', order.customerEmail),
                  ],
                ),
                const SizedBox(height: 12),
                _ItemsCard(order: order),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Payment',
                  icon: AppIcons.cardIcon,
                  rows: [
                    _Row(
                      'Method',
                      order.isCod
                          ? 'Cash on Delivery'
                          : _formatPaymentType(order.paymentType),
                    ),
                    _Row(
                      'Status',
                      order.isPaid ? 'Paid' : 'Unpaid',
                      valueColor: order.isPaid
                          ? AppColors.darkGreen
                          : AppColors.amberDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Order Info',
                  icon: AppIcons.faqIcon,
                  rows: [
                    _Row('Order #', order.orderNumber),
                    _Row('Date', order.date),
                  ],
                ),
                if (order.canMarkPaid) ...[
                  const SizedBox(height: 20),
                  _DetailMarkAsPaidButton(orderId: order.id),
                ],
                if (order.canUpdateStatus) ...[
                  const SizedBox(height: 12),
                  _DetailUpdateStatusButton(),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  static String _formatPaymentType(String raw) {
    if (raw.isEmpty) return '—';
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1);
        })
        .join(' ');
  }
}

// ── Items card ────────────────────────────────────────────────────────────────

class _ItemsCard extends StatelessWidget {
  final SellerOrder order;
  const _ItemsCard({required this.order});

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
          Row(
            children: [
              SvgIcon(
                assetName: AppIcons.ordersIcon,
                size: 16,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              CustomText(
                text: 'Items (${order.items.length})',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w700,
                color: AppColors.black2,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.lightGrey2),
          const SizedBox(height: 12),
          ...order.items.map((item) => _ItemRow(item: item)),
          const Divider(height: 1, color: AppColors.lightGrey2),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: 'Total',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
              CustomText(
                text: '\$${order.amount.toStringAsFixed(2)}',
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final SellerOrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: item.productName,
                  fontSize: AppFontSize.verySmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                OrderTypeBadge(type: item.type),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: 'x${item.quantity}',
                fontSize: AppFontSize.tiny,
                color: AppColors.lightGrey5,
              ),
              const SizedBox(height: 2),
              CustomText(
                text: '\$${item.totalPrice.toStringAsFixed(2)}',
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Detail Update Status button ───────────────────────────────────────────────

class _DetailUpdateStatusButton extends StatelessWidget {
  const _DetailUpdateStatusButton();

  @override
  Widget build(BuildContext context) {
    final detailCtrl = Get.find<SellerOrderDetailController>();
    final ordersCtrl = Get.find<SellerOrdersController>();
    return GestureDetector(
      onTap: () async {
        await OrderStatusPickerSheet.show(detailCtrl.order.value, ordersCtrl);
        detailCtrl.syncFromParent();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.07),
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_vert_rounded,
                size: 16, color: AppColors.primaryColor),
            SizedBox(width: 8),
            CustomText(
              text: 'Update Order Status',
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail Mark as Paid button ────────────────────────────────────────────────

class _DetailMarkAsPaidButton extends StatelessWidget {
  final String orderId;
  const _DetailMarkAsPaidButton({required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SellerOrdersController>();
    return Obx(() {
      final isLoading = controller.isMarkingPaid(orderId);
      return GestureDetector(
        onTap: isLoading
            ? null
            : () async {
                final success = await controller.markOrderPaid(orderId);
                if (success) Get.back();
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payments_outlined,
                        size: 16, color: AppColors.white),
                    SizedBox(width: 8),
                    CustomText(
                      text: 'Mark as Paid',
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}

// ── Status header card ────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final SellerOrder order;
  const _StatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: SvgIcon(
              assetName: AppIcons.ordersIcon,
              color: AppColors.accentColor,
            ),
          ),
          const SizedBox(height: 12),
          OrderStatusBadge(status: order.status),
          const SizedBox(height: 6),
          CustomText(
            text: order.orderNumber,
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.bold,
            color: AppColors.black2,
          ),
          const SizedBox(height: 2),
          CustomText(
            text: order.date,
            fontSize: AppFontSize.tiny,
            color: AppColors.lightGrey5,
          ),
        ],
      ),
    );
  }
}

// ── Generic info card ─────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final String icon;
  final List<_Row> rows;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

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
          Row(
            children: [
              SvgIcon(assetName: icon, size: 16, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              CustomText(
                text: title,
                fontSize: AppFontSize.verySmall,
                fontWeight: FontWeight.w700,
                color: AppColors.black2,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.lightGrey2),
          const SizedBox(height: 12),
          ...rows.map((r) => _RowWidget(row: r)),
        ],
      ),
    );
  }
}

// ── Row data + widget ─────────────────────────────────────────────────────────

class _Row {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.valueColor});
}

class _RowWidget extends StatelessWidget {
  final _Row row;
  const _RowWidget({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: CustomText(
              text: row.label,
              fontSize: AppFontSize.verySmall,
              color: AppColors.lightGrey5,
            ),
          ),
          Expanded(
            child: CustomText(
              text: row.value.isEmpty ? '—' : row.value,
              fontSize: AppFontSize.verySmall,
              fontWeight: FontWeight.w500,
              color: row.valueColor ?? AppColors.black2,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
