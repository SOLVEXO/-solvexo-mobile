import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_orders/controllers/seller_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: style.label,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: style.fg,
      ),
    );
  }

  static _BadgeStyle _resolveStyle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const _BadgeStyle('Pending', AppColors.amberDark, AppColors.yellowBg);
      case OrderStatus.processing:
        return const _BadgeStyle('Processing', AppColors.iosBlue, AppColors.lightBlue);
      case OrderStatus.shipped:
        return const _BadgeStyle('Shipped', Color(0xFF7B5EA7), Color(0xFFF3EEFF));
      case OrderStatus.completed:
        return const _BadgeStyle('Completed', AppColors.darkGreen, AppColors.greenContainerInnerColor);
      case OrderStatus.refunded:
        return const _BadgeStyle('Refunded', AppColors.red, AppColors.lightRed);
      default:
        return const _BadgeStyle('All', AppColors.grey, AppColors.background);
    }
  }
}

class _BadgeStyle {
  final String label;
  final Color fg;
  final Color bg;
  const _BadgeStyle(this.label, this.fg, this.bg);
}
