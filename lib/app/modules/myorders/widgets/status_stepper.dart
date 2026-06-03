import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/myorders/controllers/my_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusStepper extends StatelessWidget {
  StatusStepper({super.key});

  final controller = Get.find<MyOrdersController>();

  final steps = [
    _StepData("Process", AppIcons.billsIcon),
    _StepData("Deliver", AppIcons.truckIcon),
    _StepData("In Transit", AppIcons.inTransitIcon),
    _StepData("Delivered", AppIcons.deliveryCompleted),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStep = controller.currentStep;

      return Row(
        spacing: 40,
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;

          return Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (index != 0)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: isCompleted
                              ? AppColors.primaryColor
                              : AppColors.lightGrey,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? AppColors.primaryColor
                            : AppColors.lightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: SvgIcon(
                        assetName: steps[index].icon,
                        size: 24,
                        color: AppColors.white,
                      ),
                    ),
                    if (index != steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          color: isCompleted
                              ? AppColors.primaryColor
                              : AppColors.lightGrey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomText(
                  textAlign: TextAlign.center,
                  text: steps[index].title,
                  fontSize: AppFontSize.small2,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isCompleted || isActive
                      ? AppColors.primaryColor
                      : AppColors.lightGrey,
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}

class _StepData {
  final String title;
  final String icon;
  const _StepData(this.title, this.icon);
}
