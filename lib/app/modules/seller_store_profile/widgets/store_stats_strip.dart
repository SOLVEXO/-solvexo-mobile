import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';

class StoreStatsStrip extends StatelessWidget {
  final SellerStoreProfileController c;
  const StoreStatsStrip({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            StoreStatCell(value: '${c.productCount}', label: 'Products'),
            _vDivider(),
            StoreStatCell(value: '${c.orderCount}', label: 'Orders'),
            _vDivider(),
            StoreStatCell(
              value: '${c.rating}',
              label: 'Rating',
              icon: AppIcons.fillStar,
            ),
            _vDivider(),
            StoreStatCell(value: '${c.reviewCount}', label: 'Reviews'),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 36, color: AppColors.lightGrey2);
}

class StoreStatCell extends StatelessWidget {
  final String value;
  final String label;
  final String? icon;
  final Color? iconColor;

  const StoreStatCell({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                SvgIcon(
                  assetName: icon ?? AppIcons.fillStar,
                  size: 14,
                  color: iconColor,
                ),
                const SizedBox(width: 2),
              ],
              CustomText(
                text: value,
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 2),
          CustomText(
            text: label,
            fontSize: AppFontSize.tiny,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }
}
