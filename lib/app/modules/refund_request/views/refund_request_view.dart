import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/recent_order.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/myorders/models/my_order_model.dart';
import 'package:book_store_app/app/modules/refund_request/controllers/refund_request_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RefundRequestView extends StatelessWidget {
  RefundRequestView({super.key});
  final controller = Get.put(RefundRequestController());
  final OrderModel order = Get.arguments as OrderModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: "Request Refund"),
      body: Obx(() {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Order Header
              RecentOrder(orders: order),

              const SizedBox(height: 20),

              /// Issue Selection
              if (controller.selectedIssue.value == null)
                _issueList()
              else
                _detailsSection(),

              const Spacer(),

              /// Continue Button
              Obx(
                () => AppButton(
                  iconWidget: controller.isLoading.value
                      ? CircularProgressIndicator(color: AppColors.background)
                      : SizedBox(),
                  label: controller.isLoading.value ? "Submitting" : "Submit Request",
                  onPressed: controller.canContinue
                      ? () {
                          controller.submitRefund(order);
                        }
                      : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _issueList() {
    return Obx(
      () => Container(
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: "What is the issue with your item?",
              fontWeight: FontWeight.w800,
              fontSize: AppFontSize.regular,
            ),
            ...controller.issues.entries.map((e) {
              final selected = controller.selectedIssue.value == e.key;
              return GestureDetector(
                onTap: () => controller.selectedIssue.value = e.key,
                child: Container(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: e.value,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSize.small,
                          color: AppColors.gray600,
                        ),
                      ),
                      Icon(
                        selected ? Icons.radio_button_checked : Icons.radio_button_off,
                        size: 27,
                        color: selected ? AppColors.primaryColor : AppColors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _detailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "What is the issue with your item?",
          fontWeight: FontWeight.w800,
          fontSize: AppFontSize.regular,
        ),
        Obx(
          () => ListTile(
            contentPadding: EdgeInsets.zero,
            title: CustomText(
              text: controller.issues[controller.selectedIssue.value] ?? '',
              fontWeight: FontWeight.w500,
              fontSize: AppFontSize.small,
            ),
            trailing: SvgIcon(assetName: AppIcons.chevronRight, size: 20),
            onTap: () => controller.selectedIssue.value = null,
          ),
        ),
        const SizedBox(height: 8),

        /// Message
        const CustomText(
          text: "Additional details (optional)",
          fontWeight: FontWeight.w600,
          fontSize: AppFontSize.small,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.messageController,
          hintText: "Tell the seller more about the issue",
          maxLines: 4,
          isborder: true,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}
