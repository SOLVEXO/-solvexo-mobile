import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/seller_store_profile/controllers/seller_store_profile_controller.dart';
import 'package:book_store_app/app/modules/seller_store_profile/widgets/store_pinned_products_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Entry point tile for the pinned-products merchandising sheet — shows how
/// many products are currently pinned to the storefront.
class StorePinnedProductsCard extends StatelessWidget {
  final SellerStoreProfileController c;
  const StorePinnedProductsCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.allPadding),
      child: Obx(() {
        final store = c.store.value;
        final count = store?.pinnedProductIds.length ?? 0;
        return GestureDetector(
          onTap: store == null ? null : () => StorePinnedProductsSheet.show(context, c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: _cardDeco(),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppDimen.borderRadius),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.push_pin_outlined, size: 18, color: AppColors.primaryColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        text: 'Pinned Products',
                        fontSize: AppFontSize.verySmall,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black2,
                      ),
                      const SizedBox(height: 2),
                      CustomText(
                        text: '$count selected',
                        fontSize: AppFontSize.tiny,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.lightGrey5),
              ],
            ),
          ),
        );
      }),
    );
  }
}

BoxDecoration _cardDeco() => BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppDimen.serviceCountTileRadius),
      boxShadow: [
        BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    );
