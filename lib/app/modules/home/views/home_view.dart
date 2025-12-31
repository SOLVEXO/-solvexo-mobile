import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/components/home_shimmer_view.dart';
import 'package:book_store_app/app/components/main_app_bar.dart';
import 'package:book_store_app/app/components/svg_icon.dart';
import 'package:book_store_app/app/modules/category/controllers/category_controller.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/widgets/banner_carousel.dart';
import 'package:book_store_app/app/modules/home/widgets/category_item.dart';
import 'package:book_store_app/app/modules/home/widgets/product_card.dart';
import 'package:book_store_app/app/modules/home/widgets/tab_header.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/config/resources/app_icons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final controller = Get.put(HomeController());
    final categoryController = Get.put(CategoryController());

    return Scaffold(
      appBar: MainAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const HomeShimmerView();
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: AppColors.white,
                child: ListTile(
                  leading: SvgIcon(
                    assetName: AppIcons.locationIcon,
                    color: AppColors.primaryColor,
                    size: 50,
                  ),
                  title: CustomText(text: "Delivery to"),
                  subtitle: CustomText(
                    text: "Karachi, Pakistan, 24532",
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w500,
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.expand_more_rounded, size: 30),
                  ),
                ),
              ),

              /// 🔹 Location bar UI space (you will put your own)
              SizedBox(height: 15),

              /// 🔹 Banner
              BannerCarousel(),

              SizedBox(height: 18),

              /// 🔹 Categories
              SizedBox(
                height: height / 3.25,
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  itemCount: categoryController.categories.length,
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 rows FIXED!
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 0,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (_, i) {
                    final item = categoryController.categories[i];
                    return CategoryItem(image: item.icon, title: item.title);
                  },
                ),
              ),

              SizedBox(height: 10),

              /// 🔹 Tabs Header
              TabHeader(),

              SizedBox(height: 15),

              /// 🔹 Product grid
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: w >= 390 ? 2 : 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.66,
                    ),
                    itemBuilder: (_, i) {
                      final item = controller.filteredProducts[i];

                      return ProductCard(
                        name: item.name,
                        image: item.image,
                        price: item.price.toString(),
                        rating: item.rating,
                        reviews: item.reviews.toString(),
                        disc: item.description,
                        index: i,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
