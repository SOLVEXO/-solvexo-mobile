import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentOrder extends StatelessWidget {
  final bool isRefundView;
  final OrderModel orders;
  const RecentOrder({
    super.key,
    this.isRefundView = false,
    required this.orders,
  });
  @override
  Widget build(BuildContext context) {
    final order = orders;
    final allItems = order.allItems;
    if (allItems.isEmpty) return const SizedBox.shrink();
    final orderItem = allItems.first;
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: "Order Number: ${orderItem.productId.codeUnitAt(8)}",
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.w600,
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.green2.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: CustomText(
                text: order.orderStatus,
                color: AppColors.green2,
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        CustomText(text: order.createdAt.toString(), color: AppColors.greyDefault),

        Row(
          children: [
            Expanded(
              child: ListTile(
                leading: CommonImageView(url: orderItem.image, width: 50),
                title: CustomText(
                  text: orderItem.name,
                  fontSize: AppFontSize.small,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: CustomText(
                  text: "${orderItem.quantity} item",
                  fontSize: AppFontSize.small2,
                  color: AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
        Divider(height: 0),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total Transaction", style: TextStyle(color: AppColors.greyDefault)),
            Text(
              "\$${orderItem.price}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        isRefundView
            ? SizedBox()
            : Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: AppButton(
                      label: "Track Order",
                      onPressed: () {
                        Get.toNamed(Routes.orderTrackingView);
                      },
                      isOutlined: true,
                      textColor: AppColors.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      label: "Request Refund",
                      onPressed: () {
                        Get.toNamed(Routes.refundRequestView, arguments: order);
                      },
                      isOutlined: true,
                      textColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
