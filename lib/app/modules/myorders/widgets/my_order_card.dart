import 'package:book_store_app/app/components/common_image_view.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: const BoxDecoration(color: AppColors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderHeader(order: order),
          const SizedBox(height: 10),

          ListView.builder(
            itemCount: order.orderItems.length,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            itemBuilder: (context, index) {
              final orderDetail = order.orderItems[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonImageView(
                      url: orderDetail.image,
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 10),

                    /// Expanded allowed inside Row
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: orderDetail.name,
                            fontSize: AppFontSize.small,
                            fontWeight: FontWeight.w700,
                          ),
                          CustomText(
                            text: "Qty: ${orderDetail.quantity}",
                            color: AppColors.gray600,
                          ),
                        ],
                      ),
                    ),

                    CustomText(
                      text: "\$${orderDetail.price.toStringAsFixed(2)}",
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Transaction"),
              Text(
                "\$${order.totalPrice.toStringAsFixed(2)}",
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
