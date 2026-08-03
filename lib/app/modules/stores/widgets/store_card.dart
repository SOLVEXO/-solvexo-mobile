import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/data/models/storefront/store_list_item_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Full-width store row — used by the Stores browse screen and the Search
/// view's "Stores" result tab. Tapping always opens the existing buyer
/// storefront screen via the store's `slug`.
class StoreCard extends StatelessWidget {
  final StoreListItemModel store;
  const StoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.sellerStorefront, arguments: {'slug': store.slug}),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(BaseSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.md),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          children: [
            ClipOval(
              child: CommonImageView(
                url: store.logo,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: BaseSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.textPrimary,
                    fontFamily: AppTextStyles.headingFontFamily,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w600,
                  ),
                  if ((store.description ?? '').trim().isNotEmpty) ...[
                    SizedBox(height: BaseSpacing.xxs / 2),
                    CustomText(
                      text: store.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.gray600,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                  SizedBox(height: BaseSpacing.xxs),
                  Row(
                    children: [
                      SvgIcon(assetName: AppIcons.fillStar, size: 13),
                      SizedBox(width: BaseSpacing.xxs / 2),
                      CustomText(
                        text: store.averageRating > 0
                            ? '${store.averageRating.toStringAsFixed(1)} (${store.reviewCount})'
                            : 'New',
                        color: AppColors.greyDefault,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(width: BaseSpacing.sm),
                      Icon(Icons.people_outline, size: 14, color: AppColors.greyDefault),
                      SizedBox(width: BaseSpacing.xxs / 2),
                      CustomText(
                        text: '${store.followersCount}',
                        color: AppColors.greyDefault,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w400,
                      ),
                      if (store.productCount != null) ...[
                        SizedBox(width: BaseSpacing.sm),
                        CustomText(
                          text: '${store.productCount} products',
                          color: AppColors.greyDefault,
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.greySwatch400),
          ],
        ),
      ),
    );
  }
}
