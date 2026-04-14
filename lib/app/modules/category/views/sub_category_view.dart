import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_bread_crumbs.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/sub_category_item.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/widgets/floating_item_row.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/banner_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubCategoryView extends StatelessWidget {
  const SubCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    final homeController = Get.put(HomeController());
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFloatingButton(),
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Obx(
          () => CustomAppBarTwo(
            title: controller
                .categories[controller.selectedCategoryIndex.value]
                .name,
            actions: [
              CustomIconButton(
                assetName: AppIcons.heartIcon,
                isPadding: true,
                size: 28,
              ),
              CartIconWithCount(),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),

            /// Header
            BannerCarousel(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// Breadcrumbs
                  Obx(
                    () => CustomBreadCrumbs(
                      categoryName: controller
                          .categories[controller.selectedCategoryIndex.value]
                          .name,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// -----------------------------
                  /// SUB CATEGORY HORIZONTAL GRID
                  /// -----------------------------
                  SizedBox(
                    height: h / 6.6,
                    child: Obx(
                      () => GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 18,
                              childAspectRatio: 1.29,
                            ),
                        itemBuilder: (_, i) {
                          final categoryObject = controller.categories[i];

                          return SubCategoryItem(
                            prodImage: categoryObject.image,
                            subCategoryName: categoryObject.name,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  CustomText(
                    text: "All Products",
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.w600,
                  ),

                  const SizedBox(height: 10),

                  /// -------------------------
                  /// PRODUCT CARD GRID VIEW
                  /// -------------------------
                  Obx(
                    () => GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (w >= 390) ? 2 : 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.60,
                      ),
                      itemBuilder: (_, i) {
                        final item = controller.products[i];
                        return ProductCard(product: item);
                      },
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
