import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecentOrder extends StatelessWidget {
  const RecentOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: "Order Number: 741214",
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
                text: "Done",
                color: AppColors.green2,
                fontSize: AppFontSize.small2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text("January, 24 2024", style: TextStyle(color: Colors.grey)),

        Row(
          children: [
            Expanded(
              child: ListTile(
                leading: SvgIcon(assetName: AppImages.sampleProduct, size: 50),
                title: CustomText(
                  text: "Hem box",
                  fontSize: AppFontSize.small,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: CustomText(
                  text: "1 item",
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
            Text("Total Transaction", style: TextStyle(color: Colors.grey)),
            Text(
              "\$19.98",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Row(
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
                  Get.toNamed(Routes.refundRequestView);
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
