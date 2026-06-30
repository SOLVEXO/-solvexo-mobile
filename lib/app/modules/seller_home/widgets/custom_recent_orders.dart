import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/skeleton.dart';
import 'package:book_store_app/app/modules/seller_home/controllers/seller_home_controller.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CustomRecentOrders extends StatelessWidget {
  CustomRecentOrders({super.key});
  final SellerHomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _RecentOrdersShimmer();
      }
      final orders = controller.recentOrders;
      if (orders.isEmpty) {
        return _EmptyOrders();
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _OrderCard(order: orders[i]),
      );
    });
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final SellerOrder order;
  const _OrderCard({required this.order});

  static Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.completed => AppColors.greenSuccess,
        OrderStatus.processing => AppColors.iosBlue,
        OrderStatus.shipped => const Color(0xFF5856D6),
        OrderStatus.refunded => AppColors.lightGrey5,
        _ => AppColors.iosOrange,
      };

  static String _statusLabel(OrderStatus s) => switch (s) {
        OrderStatus.completed => 'Completed',
        OrderStatus.processing => 'Processing',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.refunded => 'Refunded',
        _ => 'Pending',
      };

  String get _itemsSummary {
    final items = order.items;
    if (items.isEmpty) return order.primaryProductName;
    if (items.length == 1) return items.first.productName;
    return '${items.first.productName} +${items.length - 1} more';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.status);
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.sellerOrderDetail, arguments: order),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: order.orderNumber,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 3),
                  CustomText(
                    text: order.customerName,
                    fontSize: 13,
                    color: AppColors.black87,
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: _itemsSummary,
                    fontSize: 12,
                    color: AppColors.lightGrey5,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: CustomText(
                    text: _statusLabel(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                CustomText(
                  text: '\$${order.amount.toStringAsFixed(2)}',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 2),
                CustomText(
                  text: order.date,
                  fontSize: 11,
                  color: AppColors.lightGrey5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: const Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 36, color: AppColors.lightGrey5),
            SizedBox(height: 10),
            CustomText(
              text: 'No orders yet',
              fontSize: 14,
              color: AppColors.lightGrey5,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _RecentOrdersShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(height: 14, width: 80),
                  SizedBox(height: 6),
                  Skeleton(height: 11, width: 100),
                  SizedBox(height: 5),
                  Skeleton(height: 11, width: 140),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Skeleton(height: 22, width: 80, cornerRadius: 20),
                  SizedBox(height: 6),
                  Skeleton(height: 13, width: 50),
                  SizedBox(height: 4),
                  Skeleton(height: 10, width: 70),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
