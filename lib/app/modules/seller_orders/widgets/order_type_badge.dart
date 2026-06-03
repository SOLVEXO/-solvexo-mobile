import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class OrderTypeBadge extends StatelessWidget {
  final String type;

  const OrderTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDigital = type == 'Digital';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDigital ? AppColors.lightBlue : AppColors.lightCameo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomText(
        text: type,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: isDigital ? AppColors.blue : AppColors.orange,
      ),
    );
  }
}
