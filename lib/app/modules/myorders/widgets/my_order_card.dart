import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/models/order_item_model.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_actions.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_header.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class MyOrderCard extends StatelessWidget {
  final OrderModel order;
  const MyOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: BaseSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
        boxShadow: BaseShadows.forLevel(BaseElevation.level1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.xs + 2, BaseSpacing.md, BaseSpacing.xs),
            child: OrderHeader(order: order),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.background),

          // ── Stores + items ────────────────────────────────────────
          ...order.stores.map((store) => _StoreSection(store: store)),

          const Divider(height: 1, thickness: 1, color: AppColors.background),

          // ── Total + payment ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: order.isPaid ? 'Paid' : 'Unpaid',
                      color: order.isPaid ? const Color(0xFF22C55E) : AppColors.orange,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w600,
                    ),
                    CustomText(
                      text: order.paymentType.replaceAll('_', ' ').toUpperCase(),
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(text: 'Total', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w400),
                    CustomText(
                      text: order.formattedTotal,
                      color: AppColors.black,
                      fontSize: AppFontSize.extraSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Actions ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(BaseSpacing.md, 0, BaseSpacing.md, BaseSpacing.xs + 2),
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
          padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.xs + 2, BaseSpacing.md, BaseSpacing.xxs + 2),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: _storeStatusColor, shape: BoxShape.circle),
              ),
              SizedBox(width: BaseSpacing.xxs + 2),
              CustomText(
                text: store.status[0].toUpperCase() + store.status.substring(1),
                color: _storeStatusColor,
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
              ),
              if (store.tracking != null) ...[
                const Spacer(),
                CustomText(
                  text: '${store.tracking!.carrier} · ${store.tracking!.trackingNumber}',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ],
          ),
        ),
        // Items
        ...store.items.map((item) => _OrderItemRow(item: item)),
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
      padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.xxs, BaseSpacing.md, BaseSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CommonImageView(
            url: item.image,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(BaseRadius.sm),
          ),
          SizedBox(width: BaseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: item.name,
                  color: AppColors.black2,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: BaseSpacing.xxs / 2),
                CustomText(text: "Qty: ${item.quantity}", color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w400),
              ],
            ),
          ),
          SizedBox(width: BaseSpacing.xs),
          CustomText(
            text: '\$${item.totalPrice.toStringAsFixed(2)}',
            color: AppColors.black,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
