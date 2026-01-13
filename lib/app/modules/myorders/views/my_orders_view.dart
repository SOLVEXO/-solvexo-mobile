import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/myorders/views/order_tracking_view.dart';
import 'package:book_store_app/app/modules/myorders/widgets/my_order_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/my_orders_controller.dart';

class MyOrdersView extends StatelessWidget {
  MyOrdersView({super.key});
  final controller = Get.put(MyOrdersController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: CustomTextField(
          hintText: "Search Order",
          isborder: true,
          prefixIcon: SvgIcon(assetName: AppIcons.searchIcon),
        ),
        backgroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          Obx(
            () => Container(
              padding: EdgeInsets.only(top: 20),
              color: AppColors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  controller.tabs.length,
                  (i) => GestureDetector(
                    onTap: () => controller.changeTab(i),
                    child: Column(
                      spacing: 5,
                      children: [
                        CustomText(
                          text: controller.tabs[i],
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.bold,
                          color: controller.selectedTab.value == i
                              ? AppColors.primaryColor
                              : Colors.grey,
                        ),
                        AnimatedContainer(
                          curve: Curves.bounceInOut,
                          duration: Duration(milliseconds: 200),
                          height: 7,
                          width: 40,
                          color: controller.selectedTab.value == i
                              ? AppColors.primaryColor
                              : AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(height: 0, thickness: 3, color: AppColors.background),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.filteredOrders.length,
                itemBuilder: (_, i) {
                  final order = controller.filteredOrders[i];
                  if (order.isNull) {
                    return Center(child: CustomText(text: "NO order Found!"));
                  }
                  return GestureDetector(
                    onTap: () => Get.to(() => OrderTrackingView(index: i)),
                    child: MyOrderCard(order: order),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
