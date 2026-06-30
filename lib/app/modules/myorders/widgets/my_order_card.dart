import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_actions.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_header.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class MyOrderCard extends StatelessWidget {
  final OrderModel order;
  const MyOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: OrderHeader(order: order),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.background),

          // ── Stores + items ────────────────────────────────────────
          ...order.stores.map((store) => _StoreSection(store: store)),

          const Divider(height: 1, thickness: 1, color: AppColors.background),

          // ── Total + payment ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: order.isPaid ? 'Paid' : 'Unpaid',
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                      color: order.isPaid
                          ? const Color(0xFF22C55E)
                          : AppColors.orange,
                    ),
                    CustomText(
                      text: order.paymentType
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                      fontSize: AppFontSize.tiny,
                      color: AppColors.gray600,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: 'Total',
                      fontSize: AppFontSize.tiny,
                      color: AppColors.gray600,
                    ),
                    CustomText(
                      text: order.formattedTotal,
                      fontSize: AppFontSize.small,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Actions ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: OrderActions(order: order),
          ),
        ],
      ),
    );
  }
}

// ── Single store section ──────────────────────────────────────────────────────

class _StoreSection extends StatelessWidget {
  final OrderStore store;
  const _StoreSection({required this.store});

  Color get _storeStatusColor {
    switch (store.status) {
      case 'shipped':    return const Color(0xFF3B82F6);
      case 'delivered':
      case 'completed':  return const Color(0xFF22C55E);
      case 'processing': return const Color(0xFFF59E0B);
      case 'cancelled':  return const Color(0xFFEF4444);
      default:           return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store status row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _storeStatusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              CustomText(
                text: store.status[0].toUpperCase() + store.status.substring(1),
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
                color: _storeStatusColor,
              ),
              if (store.tracking != null) ...[
                const Spacer(),
                CustomText(
                  text: '${store.tracking!.carrier} · ${store.tracking!.trackingNumber}',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.gray600,
                ),
              ],
            ],
          ),
        ),
        // Items
        ...store.items.map((item) => _OrderItemRow(item: item)),
        if (store != store) const SizedBox(height: 4),
      ],
    );
  }
}

// ── Single item row ───────────────────────────────────────────────────────────

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CommonImageView(
            url: item.image,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: item.name,
                  fontSize: AppFontSize.extraSmall,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: 'Qty: ${item.quantity}',
                  fontSize: AppFontSize.tiny,
                  color: AppColors.gray600,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CustomText(
            text: '\$${item.totalPrice.toStringAsFixed(2)}',
            fontSize: AppFontSize.extraSmall,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ],
      ),
    );
  }
}
