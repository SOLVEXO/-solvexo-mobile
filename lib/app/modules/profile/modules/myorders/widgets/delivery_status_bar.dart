import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/profile/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryStatusBar extends StatelessWidget {
  DeliveryStatusBar({super.key});
  final controller = Get.find<MyOrdersController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStep = controller.currentStatus.value;
      if (currentStep == OrderDeliveryStatus.process) {
        return SizedBox();
      }
      return GestureDetector(
        onTap: () => Get.toNamed(Routes.trackerView),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(width: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 10,
                children: [
                  SvgIcon(assetName: AppIcons.truckIcon),
                  CustomText(
                    text: currentStep == OrderDeliveryStatus.deliver
                        ? "Pakage picked up"
                        : currentStep == OrderDeliveryStatus.inTransit
                        ? "Arrived at logistic delivery hub"
                        : currentStep == OrderDeliveryStatus.delivered
                        ? "Delivered"
                        : "",
                    fontSize: AppFontSize.regular,
                    fontWeight: FontWeight.w700,
                  ),
                  Spacer(),
                  SvgIcon(assetName: AppIcons.chevronRight),
                ],
              ),
              CustomText(
                text: currentStep == OrderDeliveryStatus.deliver
                    ? "Your pakage has left the sorting center."
                    : currentStep == OrderDeliveryStatus.inTransit
                    ? "Your pakage is on the way to the delivery hub."
                    : currentStep == OrderDeliveryStatus.delivered
                    ? "Your pakage has Delivered. Recipient costomer"
                    : "",
                fontSize: AppFontSize.small2,
                color: AppColors.gray600,
              ),
            ],
          ),
        ),
      );
    });
  }
}
