import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_bread_crumbs.dart';
import 'package:book_store_app/app/components/custom_catagory_header.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/sub_category_item.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/widgets/floating_item_row.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/config/resources/app_images.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubCategoryView extends StatelessWidget {
  const SubCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController());
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFloatingButton(),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Obx(
          () => CustomAppBarTwo(
            title: controller
                .categories[controller.selectedCategoryIndex.value]
                .title,
            actions: const [
              CustomIconButton(
                assetName: AppIcons.heartIcon,
                isPadding: true,
                size: 28,
              ),
              CustomIconButton(
                assetName: AppIcons.cartIcon,
                isPadding: true,
                size: 28,
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              CustomCatagoryHeader(
                title: "Nice and Tidy",
                desc: "Get orgonized with best selling Storage system",
                productImage: AppImages.sampleProduct,
              ),
              const SizedBox(height: 10),

              /// Breadcrumbs
              Obx(
                () => CustomBreadCrumbs(
                  categoryName: controller
                      .categories[controller.selectedCategoryIndex.value]
                      .title,
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
                    itemCount: controller
                        .categories[controller.selectedCategoryIndex.value]
                        .children
                        .length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 18,
                          childAspectRatio: 1.29,
                        ),
                    itemBuilder: (_, i) {
                      final categoryObject = controller
                          .categories[controller.selectedCategoryIndex.value];

                      return SubCategoryItem(
                        prodImage: AppImages.sampleProduct,
                        subCategoryName: categoryObject.children[i],
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
                    childAspectRatio: 0.66,
                  ),
                  itemBuilder: (_, i) {
                    final item = controller.products[i];

                    return ProductCard(
                      name: item.name,
                      image: item.image,
                      price: item.price.toString(),
                      rating: item.rating.toDouble(),
                      reviews: item.reviews.toString(),
                      disc: item.description,
                      index: i,
                    );
                  },
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
