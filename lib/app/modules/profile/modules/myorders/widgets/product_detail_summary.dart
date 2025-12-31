import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/profile/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailSummary extends StatelessWidget {
  const ProductDetailSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        CustomText(
          text: "Order Summary",
          fontSize: AppFontSize.medium,
          fontWeight: FontWeight.w800,
        ),
        _row("Sub Total", controller.subTotal),
        _row("Shipping", controller.shipping),
        _row("Discount", -controller.discount),
        const Divider(),
        _row("Total", controller.total, bold: true),
      ],
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            fontSize: AppFontSize.regular,
            fontWeight: FontWeight.w500,
          ),
          CustomText(
            text: "\$${value.toStringAsFixed(2)}",
            fontSize: AppFontSize.regular,

            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
