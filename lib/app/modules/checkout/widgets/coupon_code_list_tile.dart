import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/theme/base_typography.dart';
import 'package:flutter/material.dart';

class CouponCodeListTile extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final Color? color;
  final String? subTitle;
  final bool isSubtitle;
  const CouponCodeListTile({
    super.key,
    this.isSubtitle = false,
    required this.title,
    this.onTap,
    this.color,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.3),
        borderRadius: BorderRadius.circular(BaseRadius.lg),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSubtitle ? AppColors.primaryColor : AppColors.gray600,
          child: const Icon(Icons.local_offer_outlined, color: AppColors.white),
        ),
        title: Text(
          title,
          style: BaseTypography.bodyMedium(
            color: isSubtitle ? AppColors.primaryColor : AppColors.black,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: isSubtitle ? Text(subTitle ?? "", style: BaseTypography.bodySmall(color: AppColors.black)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
