import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/product_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
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

  @override
  Widget build(BuildContext context) {
    final productController = Get.put(ProductController());

    return GestureDetector(
      onTap: () => productController.openProductDetails(product),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppDimen.allPadding,
          0,
          AppDimen.allPadding,
          12,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Thumbnail ───────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
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

            const SizedBox(width: 12),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.name,
                    fontSize: AppFontSize.small2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // "by Seller · ⭐ rating"
                  Row(
                    children: [
                      CustomText(
                        text: 'by Seller · ',
                        fontSize: AppFontSize.tiny,
                        color: AppColors.gray600,
                      ),
                      SvgIcon(
                        assetName: AppIcons.fillStar,
                        size: 11,
                        color: const Color(0xFFFACC15),
                      ),
                      const SizedBox(width: 2),
                      CustomText(
                        text: product.averageRating.toStringAsFixed(1),
                        fontSize: AppFontSize.tiny,
                        color: AppColors.gray600,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price + Buy button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: '\$${product.price.toStringAsFixed(2)}',
                        fontSize: AppFontSize.small,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                      GestureDetector(
                        onTap: () => productController.openProductDetails(product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const CustomText(
                            text: 'Buy',
                            fontSize: AppFontSize.small2,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
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
