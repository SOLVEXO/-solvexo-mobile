import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_actions.dart';
import 'package:book_store_app/app/modules/myorders/widgets/order_header.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class MyOrderCard extends StatelessWidget {
  final OrderModel order;
  const MyOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 3),
      decoration: BoxDecoration(color: AppColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderHeader(order: order),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset(order.image, height: 50),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: order.productName,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w700,
                  ),
                  CustomText(
                    text: "+ ${order.totalItems} items",
                    color: AppColors.gray600,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Transaction"),
              Text(
                "\$${order.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OrderActions(order: order),
        ],
      ),
    );
  }
}
