import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:flutter/material.dart';

/// A small circular counter overlaid on the top-right corner of [child] —
/// generic version of the pattern in `CartIconWithCount`, reused for the
/// messaging/notification unread badges on the buyer and seller app bars.
/// Renders nothing when [count] is 0.
class UnreadCountBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color badgeColor;

  const UnreadCountBadge({
    super.key,
    required this.child,
    required this.count,
    this.badgeColor = AppColors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: -6,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(color: AppColors.black.withOpacity(0.2), blurRadius: 4),
                ],
              ),
              alignment: Alignment.center,
              child: CustomText(
                text: count > 9 ? '9+' : count.toString(),
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1,
                fontFamily: AppTextStyles.monoFontFamily,
              ),
            ),
          ),
      ],
    );
  }
}
