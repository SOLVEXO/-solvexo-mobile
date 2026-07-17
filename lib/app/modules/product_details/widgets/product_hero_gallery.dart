import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/components/wishlist_heart_button.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/home/widgets/notched_image_box.dart';
import 'package:book_store_app/app/modules/product_details/controller/product_detail_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/core/theme/base_shadows.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/dimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Hero image carousel with floating back/share buttons and a wishlist heart
/// sitting inside the notch — stateless, since the `PageController` +
/// current-page index live on `ProductDetailController` (disposed in its
/// `onClose`), so this widget never needs its own `State`.
class ProductHeroGallery extends StatelessWidget {
  final ProductDetailController controller;
  final ProductModel product;

  const ProductHeroGallery({super.key, required this.controller, required this.product});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final images = controller.displayImages;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md, vertical: BaseSpacing.sm),
        child: Column(
          spacing: 20,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleIconButton(assetName: AppIcons.chevronLeft, onTap: () => Get.back()),
                _CircleIconButton(assetName: AppIcons.shareIcon),
              ],
            ),
            SizedBox(
              height: Get.height / 3.1,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: NotchedImageBox(
                      heartGap: BaseSpacing.xs,
                      heartSize: 28,
                      radius: BaseRadius.lg,
                      child: images.isEmpty
                          ? const Center(
                              child: Icon(Icons.image_outlined, color: AppColors.lightGrey7, size: 48),
                            )
                          : PageView.builder(
                              controller: controller.imagePageController,
                              onPageChanged: (i) => controller.imagePage.value = i,
                              itemCount: images.length,
                              itemBuilder: (_, i) => CommonImageView(url: images[i], fit: BoxFit.contain),
                            ),
                    ),
                  ),

                  // Wishlist heart — sitting inside the notch, top right
                  Positioned(
                    top: 0,
                    right: 0,
                    child: WishlistHeartButton(
                      productId: product.id,
                      variantId: product.variants.isNotEmpty ? product.variants.first.id : '',
                    ),
                  ),

                  // Dot indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: BaseSpacing.sm,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Obx(
                          () => SmoothIndicator(
                            offset: controller.imagePage.value.toDouble(),
                            count: images.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 6,
                              dotWidth: 6,
                              spacing: 6,
                              activeDotColor: AppColors.primaryColor,
                              dotColor: AppColors.white,
                            ),
                            size: Size(Get.width * 0.18, 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CircleIconButton extends StatelessWidget {
  final String? assetName;
  final VoidCallback? onTap;
  const _CircleIconButton({this.assetName, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(AppDimen.borderRadius),
          boxShadow: BaseShadows.forLevel(BaseElevation.level1),
        ),
        alignment: Alignment.center,
        child: SvgIcon(assetName: assetName!, size: 22),
      ),
    );
  }
}
