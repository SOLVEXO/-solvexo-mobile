import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class OrderInfo extends StatelessWidget {
  final int index;
  const OrderInfo({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyOrdersController>();
    final item = controller.orders[index];
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      color: AppColors.white,
      child: Column(
        spacing: 7,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customRow("Order Number:", item.id),
          customRow("Order Date:", item.createdAt.toString()),
          customRow("Payment Date:", item.createdAt.toString()),
        ],
      ),
    );
  }

  Widget customRow(String title, text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          text: title,
          fontSize: AppFontSize.regular,
          fontWeight: FontWeight.w600,
        ),
        CustomText(text: text, fontSize: AppFontSize.small),
      ],
    );
  }
}
