import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:book_store_app/app/data/models/enums/enums.dart';
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
        return const SizedBox();
      }
      final title = currentStep == OrderDeliveryStatus.deliver
          ? "Package picked up"
          : currentStep == OrderDeliveryStatus.inTransit
              ? "Arrived at logistic delivery hub"
              : currentStep == OrderDeliveryStatus.delivered
                  ? "Delivered"
                  : "";
      return Semantics(
        button: true,
        label: title,
        child: GestureDetector(
          onTap: () => Get.toNamed(Routes.trackerView),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: EdgeInsets.all(BaseSpacing.xl),
            decoration: BoxDecoration(
              border: Border.all(width: 0.3),
              borderRadius: BorderRadius.circular(BaseRadius.md),
            ),
            child: Column(
              spacing: BaseSpacing.xxs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: BaseSpacing.sm,
                  children: [
                    SvgIcon(assetName: AppIcons.truckIcon),
                    Text(title, style: BaseTypography.titleMedium(color: AppColors.black).copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    SvgIcon(assetName: AppIcons.chevronRight),
                  ],
                ),
                Text(
                  currentStep == OrderDeliveryStatus.deliver
                      ? "Your package has left the sorting center."
                      : currentStep == OrderDeliveryStatus.inTransit
                          ? "Your package is on the way to the delivery hub."
                          : currentStep == OrderDeliveryStatus.delivered
                              ? "Your package has been delivered."
                              : "",
                  style: BaseTypography.bodySmall(color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
