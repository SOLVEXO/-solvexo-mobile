import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// [status] is a `RefundRequestModel.status` value: 'pending' | 'approved' | 'rejected'.
class ReturnStatusBadge extends StatelessWidget {
  final String status;

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
        fontFamily: AppTextStyles.monoFontFamily,
      ),
    );
  }

  static _BadgeStyle _resolveStyle(String status) {
    switch (status) {
      case 'approved':
        return const _BadgeStyle('Approved', AppColors.darkGreen, AppColors.greenContainerInnerColor);
      case 'rejected':
        return const _BadgeStyle('Rejected', AppColors.red, AppColors.lightRed);
      case 'pending':
      default:
        return const _BadgeStyle('Pending', AppColors.amberDark, AppColors.yellowBg);
    }
  }
}

class _BadgeStyle {
  final String label;
  final Color fg;
  final Color bg;
  const _BadgeStyle(this.label, this.fg, this.bg);
}
