import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "Sold by `<store>`" row with a "Visit Store" pill when the store has a slug.
class SellerStoreCard extends StatelessWidget {
  final ProductModel product;
  const SellerStoreCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final String? slug = product.storeSlug;
    final String? name = product.storeName;
    final String? logo = product.storeLogo;
    final String? sellerName = product.sellerName;
    final String displayName = (name != null && name.isNotEmpty)
        ? name
        : (sellerName != null && sellerName.isNotEmpty)
        ? sellerName
        : 'Store';
    final String initials = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : 'S';
    final bool canVisit = slug != null && slug.isNotEmpty;

    return Semantics(
      button: canVisit,
      label: canVisit ? 'Sold by $displayName, visit store' : 'Sold by $displayName',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(BaseRadius.pill),
            child: logo != null && logo.isNotEmpty
                ? CommonImageView(url: logo, height: 36, width: 36, fit: BoxFit.cover)
                : Container(
                    height: 36,
                    width: 36,
                    color: AppColors.primaryColor.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: CustomText(
                      text: initials,
                      color: AppColors.primaryColor,
                      fontSize: AppFontSize.tiny,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          SizedBox(width: BaseSpacing.xs + 2),
          Expanded(
            child: CustomText(
              text: displayName,
              color: AppColors.black2,
              fontSize: AppFontSize.tiny,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (canVisit)
            GestureDetector(
              onTap: () => Get.toNamed(Routes.sellerStorefront, arguments: slug),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.sm, vertical: BaseSpacing.xxs + 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(BaseRadius.pill),
                  border: Border.all(color: AppColors.primaryColor, width: 1.2),
                ),
                child: CustomText(
                  text: 'Visit Store',
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
