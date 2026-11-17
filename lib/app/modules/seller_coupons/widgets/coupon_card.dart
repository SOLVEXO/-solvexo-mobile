import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/marketing/coupon_model.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  bool get _isLive => coupon.isActive && !coupon.isExpired;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.lg),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
          border: Border.all(
            color: _isLive ? AppColors.primaryColor.withOpacity(0.15) : AppColors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CodeChip(code: coupon.code, dimmed: !_isLive),
                SizedBox(width: BaseSpacing.xs),
                Expanded(
                  child: CustomText(
                    text: coupon.discountLabel,
                    color: _isLive ? AppColors.primaryColor : AppColors.gray600,
                    fontSize: AppFontSize.extraSmall,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _StatusBadge(isLive: _isLive, isExpired: coupon.isExpired),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: AppColors.gray600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BaseRadius.md)),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'toggle') onToggleActive();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: CustomText(text: 'Edit')),
                    PopupMenuItem(value: 'toggle', child: CustomText(text: coupon.isActive ? 'Deactivate' : 'Activate')),
                    PopupMenuItem(
                      value: 'delete',
                      child: CustomText(text: 'Delete', color: AppColors.red),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: BaseSpacing.sm),
            Wrap(
              spacing: BaseSpacing.sm,
              runSpacing: BaseSpacing.xxs,
              children: [
                _InfoChip(
                  icon: Icons.confirmation_number_outlined,
                  label: coupon.usageLimit != null
                      ? '${coupon.usageCount}/${coupon.usageLimit} used'
                      : '${coupon.usageCount} used',
                ),
                if (coupon.minOrderAmount != null)
                  _InfoChip(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Min \$${coupon.minOrderAmount!.toStringAsFixed(0)}',
                  ),
                if (coupon.expiresAt != null)
                  _InfoChip(
                    icon: Icons.event_outlined,
                    label: coupon.isExpired
                        ? 'Expired ${DateFormat('MMM d, yyyy').format(coupon.expiresAt!)}'
                        : 'Expires ${DateFormat('MMM d, yyyy').format(coupon.expiresAt!)}',
                    warn: coupon.isExpired,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  final String code;
  final bool dimmed;
  const _CodeChip({required this.code, required this.dimmed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs + 2, vertical: BaseSpacing.xxs),
      decoration: BoxDecoration(
        color: dimmed ? AppColors.lightGrey.withOpacity(0.4) : AppColors.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(BaseRadius.sm),
      ),
      child: CustomText(
        text: code,
        color: dimmed ? AppColors.gray600 : AppColors.primaryColor,
        fontSize: AppFontSize.tiny,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        fontFamily: AppTextStyles.monoFontFamily,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isLive;
  final bool isExpired;
  const _StatusBadge({required this.isLive, required this.isExpired});

  @override
  Widget build(BuildContext context) {
    final label = isLive ? 'Active' : (isExpired ? 'Expired' : 'Inactive');
    final color = isLive ? AppColors.greenSuccess : (isExpired ? AppColors.red : AppColors.gray600);
    return Container(
      margin: EdgeInsets.only(right: BaseSpacing.xxs),
      padding: EdgeInsets.symmetric(horizontal: BaseSpacing.xs, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(BaseRadius.pill)),
      child: CustomText(
        text: label,
        color: color,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        fontFamily: AppTextStyles.monoFontFamily,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool warn;
  const _InfoChip({required this.icon, required this.label, this.warn = false});

  @override
  Widget build(BuildContext context) {
    final color = warn ? AppColors.red : AppColors.gray600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        SizedBox(width: BaseSpacing.xxs / 2),
        CustomText(
          text: label,
          color: color,
          fontSize: AppFontSize.tiny,
          fontWeight: FontWeight.w500,
          fontFamily: AppTextStyles.monoFontFamily,
        ),
      ],
    );
  }
}
