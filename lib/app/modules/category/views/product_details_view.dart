import 'package:book_store_app/app/components/buttons/app_button.dart';
import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_icon_button.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/recommended_product_list.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/routes/app_pages.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsView extends StatelessWidget {
  ProductDetailsView({super.key});
  final controller = Get.put(CategoryController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final product = controller.selectedProduct.value;
    final date = DateTime.now().day;
    final month = DateTime.now().month;
    final year = DateTime.now().year;
    return Scaffold(
      bottomNavigationBar: _bottomBar(size, context, product),
      appBar: CustomAppBarTwo(
        backgroundColor: AppColors.background,
        actions: [
          CustomIconButton(
            onPressed: () => Get.toNamed(Routes.searchView),
            assetName: AppIcons.searchIcon,
            size: AppFontSize.extraLarge,
          ),
          CustomIconButton(
            isPadding: true,
            assetName: AppIcons.cartIcon,
            size: AppFontSize.veryLarge2,
          ),
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
                child: SvgIcon(assetName: product!.image, size: 200),
              ),
            ),
            Container(
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
                  titleText("\$ ${product.price}"),
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
                      CustomText(text: product.rating.toString()),
                      CustomText(text: "(${product.reviews})"),
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
                    "Measurement",
                    false.obs,
                    Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Small - 24',
                          fontSize: AppFontSize.regular,
                        ),
                        CustomText(
                          text: 'medium - 28',
                          fontSize: AppFontSize.regular,
                        ),
                        CustomText(
                          text: 'large - 32',
                          fontSize: AppFontSize.regular,
                        ),
                        CustomText(
                          text: 'Extra Large - 36',
                          fontSize: AppFontSize.regular,
                        ),
                      ],
                    ),
                  ),
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

  CustomText titleText(String text) {
    return CustomText(
      text: text,
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

  Widget _bottomBar(Size size, context, product) {
    return Container(
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
              onPressed: () => controller.addToCart(context, product.image),
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
