import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class SellerNameRow extends StatelessWidget {
  final String name;
  const SellerNameRow({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          CommonImageView(
            height: 20,
            width: 20,
            fit: BoxFit.cover,
            radius: BorderRadius.circular(50),
          ),
          CustomText(
            text: name,
            fontSize: AppFontSize.small2,
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }
}
