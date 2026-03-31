import 'package:book_store_app/app/bottom_bar/controllers/bottom_navbar_controller.dart';
import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/cart_icon_with_count.dart';
import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/category/models/product_model.dart';
import 'package:book_store_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsView extends StatelessWidget {
  ProductDetailsView({super.key});
  final controller = Get.put(CategoryController());
  final profileController = Get.put(ProfileController());
  final bottombarcontroller = Get.put(BottomNavController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ProductModel product = controller.selectedProduct.value!;
    final date = DateTime.now().day;
    final month = DateTime.now().month;
    final year = DateTime.now().year;
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: profileController.user.isNull
          ? null
          : _bottomBar(size, context, product),
      appBar: CustomAppBarTwo(
        backgroundColor: AppColors.background,
        actions: [
          CustomIconButton(
            onPressed: () => Get.toNamed(Routes.searchView),
            assetName: AppIcons.searchIcon,
            size: AppFontSize.extraLarge,
          ),
          CartIconWithCount(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                color: AppColors.background,
                child: CommonImageView(
                  url: product.images[0],
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: double.infinity,
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomText(
                          text: product.name,
                          fontSize: AppFontSize.medium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      CustomIconButton(
                        assetName: AppIcons.shareIcon,
                        isPadding: true,
                      ),
                      CustomIconButton(assetName: AppIcons.heartIcon),
                    ],
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      titleText(
                        "\$ ${product.price}",
                        color: AppColors.primaryColor,
                      ),
                      CustomText(
                        text: "Stock (${product.stock.toString()})",
                        fontSize: AppFontSize.small2,
                        color: product.inStock
                            ? AppColors.green2
                            : AppColors.red,
                      ),
                    ],
                  ),
                  Divider(),
                  titleText("Description"),
                  CustomText(
                    text: product.description,
                    fontSize: AppFontSize.small2,
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      SvgIcon(
                        assetName: AppIcons.fillStar,
                        size: AppFontSize.small,
                      ),
                      CustomText(text: product.ratings.toString()),

                      VerticalDivider(
                        color: AppColors.black,
                        width: 1,
                        thickness: 2,
                      ),
                      CustomText(text: "310 Sold"),
                    ],
                  ),
                  Divider(),
                  _expandTile(
                    "Reviews",
                    false.obs,
                    Column(
                      children: [
                        CustomText(
                          textAlign: TextAlign.center,
                          color: AppColors.gray600,
                          fontSize: AppFontSize.small2,
                          text:
                              '"Very good productVery good productVery good productVery good product"',
                        ),
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: CustomText(text: "Ahmed Hussain"),
                          subtitle: SizedBox(
                            height: 20,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: SvgIcon(
                                    assetName: AppIcons.fillStar,
                                    size: 15,
                                  ),
                                );
                              },
                            ),
                          ),
                          trailing: CustomText(
                            text: "Order  $date-$month-$year",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  titleText("Related Products"),
                  RecommendedProductList(),
                  // CustomVarient(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget titleText(String text, {Color color = AppColors.black}) {
    return CustomText(
      text: text,
      color: color,
      fontSize: AppFontSize.medium,
      fontWeight: FontWeight.w800,
    );
  }

  Widget _expandTile(String title, RxBool toggle, Widget content) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(),
        child: ExpansionTile(
          collapsedShape: Border(top: BorderSide.none),
          shape: Border(top: BorderSide.none),
          title: titleText(title),
          initiallyExpanded: toggle.value,
          onExpansionChanged: (v) => toggle.value = v,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(child: content),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(Size size, context, ProductModel product) {
    if (profileController.user.value.isNull) {
      return Container(
        color: AppColors.white,
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 5),
        child: AppButton(
          label: "Login",
          onPressed: () => Get.toNamed(Routes.authTabView),
        ),
      );
    }
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20, top: 5),
      child: Row(
        spacing: 10,
        children: [
          Obx(
            () => Container(
              width: size.width / 2.5,
              padding: EdgeInsets.symmetric(vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textPrimary, width: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: controller.decreaseQty,
                    icon: Icon(Icons.remove, color: AppColors.primaryColor),
                  ),
                  Text(controller.productQty.value.toString()),
                  IconButton(
                    onPressed: controller.increaseQty,
                    icon: const Icon(Icons.add, color: AppColors.primaryColor),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AppButton(
              label: "Add to cart",
              onPressed: () => controller.addToCart(context, product),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _reviewsSection() {
  //   return ExpansionTile(
  //     title: const Text("Reviews"),
  //     children: controller.map((r) {
  // return ListTile(
  //   leading: const CircleAvatar(child: Icon(Icons.person)),
  //   title: Text(r.user),
  //   subtitle: Text(r.comment),
  //   trailing: Text("⭐ ${r.rating}"),
  // );
  //     }).toList(),
  //   );
  // }
}
