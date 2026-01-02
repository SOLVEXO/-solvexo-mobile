import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import '../models/faq_model.dart';

class FaqTile extends StatelessWidget {
  final FAQModel faq;
  final VoidCallback onTap;

  const FaqTile({super.key, required this.faq, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.white),
      child: ListTile(
        title: CustomText(
          text: faq.question,
          fontSize: AppFontSize.small,
          fontWeight: FontWeight.w500,
        ),
        trailing: SvgIcon(assetName: AppIcons.chevronRight, size: 20),
        onTap: onTap,
      ),
    );
  }
}
