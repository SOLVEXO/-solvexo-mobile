import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';

/// Small tinted pill reflecting a membership's lifecycle status.
class MembershipStatusChip extends StatelessWidget {
  final String status; // active | trialing | paused | past_due | canceled
  final bool pendingCancellation;

  const MembershipStatusChip({
    super.key,
    required this.status,
    this.pendingCancellation = false,
  });

  Color get _color {
    if (pendingCancellation) return AppColors.amberDark;
    switch (status) {
      case 'active':
        return AppColors.greenSuccess;
      case 'trialing':
        return AppColors.amberDark;
      case 'paused':
        return AppColors.gray600;
      case 'past_due':
        return AppColors.red;
      case 'canceled':
        return AppColors.gray600;
      default:
        return AppColors.gray600;
    }
  }

  String get _label {
    if (pendingCancellation) return 'Ends soon';
    switch (status) {
      case 'active':
        return 'Active';
      case 'trialing':
        return 'Trialing';
      case 'paused':
        return 'Paused';
      case 'past_due':
        return 'Past due';
      case 'canceled':
        return 'Canceled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: BaseSpacing.xxs),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(BaseRadius.pill),
      ),
      child: CustomText(
        text: _label,
        color: _color,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
