import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/custom_text_field.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewsView extends StatelessWidget {
  const ReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarTwo(title: "Write a review"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
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
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                spacing: 10,
                children: [
                  CustomText(
                    text: "Rate this Product",
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.bold,
                  ),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgIcon(assetName: AppIcons.fillStar, size: 35),
                      SvgIcon(assetName: AppIcons.fillStar, size: 35),
                      SvgIcon(assetName: AppIcons.starOutlined, size: 35),
                      SvgIcon(assetName: AppIcons.starOutlined, size: 35),
                      SvgIcon(assetName: AppIcons.starOutlined, size: 35),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    text: "Message (optional)",
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.small,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hintText:
                        "What did you like or dislike about this product?",
                    maxLines: 4,
                    isborder: true,
                  ),
                ],
              ),
            ),
            Spacer(),
            AppButton(
              label: "Submit",
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
