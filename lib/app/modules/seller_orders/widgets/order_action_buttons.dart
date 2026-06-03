import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class OrderActionButtons extends StatelessWidget {
  final VoidCallback onFulfill;
  final VoidCallback onView;

  const OrderActionButtons({
    super.key,
    required this.onFulfill,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            label: 'Fulfill Order',
            onTap: onFulfill,
            filled: true,
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: onView,
          child: CustomText(text: "View", color: AppColors.primaryColor),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionBtn({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primaryColor.withOpacity(0.08)
              : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          border: Border.all(
            color: filled
                ? AppColors.primaryColor.withOpacity(0.3)
                : AppColors.lightGrey2,
          ),
        ),
        alignment: Alignment.center,
        child: CustomText(
          text: label,
          fontSize: AppFontSize.verySmall,
          fontWeight: FontWeight.w600,
          color: filled ? AppColors.primaryColor : AppColors.grey,
        ),
      ),
    );
  }
}
