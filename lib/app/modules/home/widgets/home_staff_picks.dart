import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_text_styles.dart';
import 'package:book_store_app/core/theme/base_animations.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeStaffPicks extends StatelessWidget {
  const HomeStaffPicks({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Obx(() {
      // Show first 5 products as staff picks
      final picks = controller.filteredProducts.take(5).toList();
      if (picks.isEmpty) return const SizedBox.shrink();

      return Column(
        children: picks
            .map((p) => _StaffPickItem(product: p))
            .toList(),
      );
    });
  }
}

class _StaffPickItem extends StatelessWidget {
  final ProductModel product;
  const _StaffPickItem({required this.product});

  // Was `Get.put(ProductController())` — same singleton-replacement bug as
  // `ProductCard`, but worse here: it fired once *per staff-pick row*,
  // meaning up to 5 replacements of the shared controller per screen build.
  ProductController get productController {
    if (!Get.isRegistered<ProductController>()) Get.put(ProductController());
    return Get.find<ProductController>();
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => productController.openProductDetails(product),
      child: Container(
        margin: EdgeInsets.fromLTRB(AppDimen.allPadding, 0, AppDimen.allPadding, BaseSpacing.sm),
        padding: EdgeInsets.all(BaseSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(BaseRadius.md),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Thumbnail ───────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(BaseRadius.sm),
              child: Container(
                width: 76,
                height: 76,
                color: AppColors.languageBg,
                child: product.images.isNotEmpty
                    ? CommonImageView(
                        url: product.images.first,
                        fit: BoxFit.contain,
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: AppColors.lightGrey7,
                        size: 30,
                      ),
              ),
            ),

            SizedBox(width: BaseSpacing.sm),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.name,
                    color: AppColors.black2,
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: BaseSpacing.xxs - 1),

                  // "by Seller · ⭐ rating"
                  Row(
                    children: [
                      CustomText(text: 'by Seller · ', color: AppColors.gray600, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w400),
                      SvgIcon(
                        assetName: AppIcons.fillStar,
                        size: 11,
                        color: const Color(0xFFFACC15),
                      ),
                      SizedBox(width: BaseSpacing.xxs / 2),
                      CustomText(
                        text: product.averageRating.toStringAsFixed(1),
                        color: AppColors.gray600,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),

                  SizedBox(height: BaseSpacing.xs),

                  // Price + Buy button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: '\$${product.price.toStringAsFixed(2)}',
                        color: AppColors.black,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppTextStyles.monoFontFamily,
                      ),
                      PressableScale(
                        onTap: () => productController.openProductDetails(product),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 32),
                          padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md - 2, vertical: BaseSpacing.xxs),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(BaseRadius.xs),
                          ),
                          alignment: Alignment.center,
                          child: CustomText(
                            text: 'Buy',
                            color: AppColors.white,
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
