import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/faq_model.dart';

class FAQDetailView extends StatelessWidget {
  const FAQDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final FaqModel faq = Get.arguments;

    return Scaffold(
      appBar: CustomAppBarTwo(title: "FAQ"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: faq.question,
              fontSize: AppFontSize.regular,
              fontWeight: FontWeight.w600,
            ),
            Text(faq.answer),
            Row(
              spacing: 15,
              children: [
                Expanded(
                  child: AppButton(
                    label: "Yes",
                    onPressed: () {},
                    isOutlined: true,
                    iconWidget: Icon(
                      Icons.thumb_up_alt_outlined,
                      color: AppColors.primaryColor,
                      size: 25,
                    ),
                    textColor: AppColors.primaryColor,
                  ),
                ),
                Expanded(
                  child: AppButton(
                    label: "No",
                    onPressed: () {},
                    isOutlined: true,
                    iconWidget: Icon(
                      Icons.thumb_down_alt_outlined,
                      color: AppColors.primaryColor,
                      size: 25,
                    ),
                    textColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
