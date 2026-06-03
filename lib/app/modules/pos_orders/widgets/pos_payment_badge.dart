import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/pos_orders/controllers/pos_orders_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class PosPaymentBadge extends StatelessWidget {
  final PosPaymentMethod method;

  const PosPaymentBadge({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final style = _resolve(method);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.border, width: 1),
      ),
      child: CustomText(
        text: style.label,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: style.fg,
      ),
    );
  }

  static _BadgeStyle _resolve(PosPaymentMethod method) {
    switch (method) {
      case PosPaymentMethod.card:
        return const _BadgeStyle(
          label: 'Card',
          fg: AppColors.black2,
          bg: AppColors.white,
          border: AppColors.lightGrey2,
        );
      case PosPaymentMethod.cash:
        return const _BadgeStyle(
          label: 'Cash',
          fg: AppColors.darkGreen,
          bg: AppColors.greenContainerInnerColor,
          border: AppColors.darkGreen,
        );
      case PosPaymentMethod.tap:
        return const _BadgeStyle(
          label: 'Tap',
          fg: AppColors.primaryColor,
          bg: AppColors.languageBg,
          border: AppColors.primaryColor,
        );
    }
  }
}

class _BadgeStyle {
  final String label;
  final Color fg;
  final Color bg;
  final Color border;

  const _BadgeStyle({
    required this.label,
    required this.fg,
    required this.bg,
    required this.border,
  });
}
