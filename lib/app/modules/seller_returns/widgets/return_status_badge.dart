import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_returns/controllers/seller_returns_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

class ReturnStatusBadge extends StatelessWidget {
  final ReturnStatus status;

  const ReturnStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(
        text: style.label,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w600,
        color: style.fg,
      ),
    );
  }

  static _BadgeStyle _resolveStyle(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.requested:
        return const _BadgeStyle('Requested', AppColors.amberDark, AppColors.yellowBg);
      case ReturnStatus.approved:
        return const _BadgeStyle('Approved', AppColors.darkGreen, AppColors.greenContainerInnerColor);
      case ReturnStatus.rejected:
        return const _BadgeStyle('Rejected', AppColors.red, AppColors.lightRed);
    }
  }
}

class _BadgeStyle {
  final String label;
  final Color fg;
  final Color bg;
  const _BadgeStyle(this.label, this.fg, this.bg);
}
