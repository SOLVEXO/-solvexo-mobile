import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class ConformationBottomSheetContent extends StatelessWidget {
  final Function() onConfirm;
  final String title, subTitle, btnOneText, btnTwoText;
  final Function() btnOneOnPressed, btnTweOnPressed;
  const ConformationBottomSheetContent({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.subTitle,
    required this.btnOneText,
    required this.btnTweOnPressed,
    required this.btnTwoText,
    required this.btnOneOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: AppFontSize.medium,
          ),
          const SizedBox(height: 10),
          CustomText(
            textAlign: TextAlign.center,
            text: subTitle,
            fontSize: AppFontSize.small,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: btnOneOnPressed,
                  label: btnOneText,
                  isOutlined: true,
                  textColor: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(onPressed: btnTweOnPressed, label: btnTwoText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
