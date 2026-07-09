import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailSummary extends StatelessWidget {
  final int index;
  const ProductDetailSummary({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();
    final order = controller.orders[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: BaseSpacing.xxs + 1,
      children: [
        CustomText(text: 'Order Summary', color: AppColors.black, fontSize: AppFontSize.small2, fontWeight: FontWeight.w800),
        _row("Sub Total", order.subtotal),
        _row("Shipping", order.shippingFee),
        if (order.taxAmount > 0) _row("Tax", order.taxAmount),
        const Divider(),
        _row("Total", order.totalAmount, bold: true),
      ],
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: BaseSpacing.xxs, horizontal: BaseSpacing.md - 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(text: label, color: AppColors.black, fontSize: AppFontSize.small2, fontWeight: FontWeight.w500),
          CustomText(
            text: "\$${value.toStringAsFixed(2)}",
            color: AppColors.black,
            fontSize: AppFontSize.small2,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
