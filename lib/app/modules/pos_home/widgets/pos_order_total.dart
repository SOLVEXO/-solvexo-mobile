import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_home/controllers/pos_home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosOrderTotal extends StatelessWidget {
  final PosHomeController c;
  const PosOrderTotal({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.lightGrey2),
          bottom: BorderSide(color: AppColors.lightGrey2),
        ),
      ),
      child: Column(children: [
        _TotalRow(
          label: 'Subtotal',
          value: '\$${c.subtotal.toStringAsFixed(2)}',
          isBold: false,
        ),
        const SizedBox(height: 6),
        _TotalRow(
          label: 'Tax (${(PosHomeController.taxRate * 100).toStringAsFixed(0)}%)',
          value: '\$${c.tax.toStringAsFixed(2)}',
          isBold: false,
        ),
        const Divider(height: 14, color: AppColors.lightGrey2),
        _TotalRow(
          label: 'Total',
          value: '\$${c.total.toStringAsFixed(2)}',
          isBold: true,
          valueColor: AppColors.primaryColor,
          fontSize: AppFontSize.medium,
        ),
      ]),
    ));
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final double fontSize;
  const _TotalRow({
    required this.label,
    required this.value,
    required this.isBold,
    this.valueColor,
    this.fontSize = AppFontSize.verySmall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CustomText(
        text: label,
        fontSize: fontSize,
        color: isBold ? AppColors.black2 : AppColors.grey,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      const Spacer(),
      CustomText(
        text: value,
        fontSize: fontSize,
        color: valueColor ?? (isBold ? AppColors.black2 : AppColors.grey),
        fontWeight: FontWeight.bold,
      ),
    ]);
  }
}
