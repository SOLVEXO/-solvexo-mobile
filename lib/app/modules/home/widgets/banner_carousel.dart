import 'dart:async';
import 'package:book_store_app/app/components/custom_catagory_header.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BannerCarousel extends StatelessWidget {
  BannerCarousel({super.key});

  final c = Get.find<HomeController>();
  final PageController controllerPage = PageController();

  @override
  Widget build(BuildContext context) {
    // Start auto-scroll when widget is built
    _startAutoScroll();
    if (c.banners.isEmpty) {
      return Shimmer.fromColors(
        baseColor: AppColors.gray600,
        highlightColor: AppColors.acceptedBg,
        child: SizedBox(height: Get.height / 5, width: double.infinity),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: Get.height / 5,
          child: PageView.builder(
            controller: controllerPage,
            onPageChanged: (i) => c.bannerIndex.value = i,
            itemCount: c.banners.length,
            itemBuilder: (_, i) {
              final item = c.banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomCatagoryHeader(productImage: item.image),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        Obx(
          () => SmoothIndicator(
            offset: c.bannerIndex.toDouble(),
            count: c.banners.length,
            effect: ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              spacing: 6,
              activeDotColor: AppColors.primaryColor,
              dotColor: AppColors.shimmerBase,
            ),
            size: Size(Get.width * 0.18, 20),
          ),
        ),
      ],
    );
  }

  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (controllerPage.hasClients && c.banners.isNotEmpty) {
        int nextPage = (c.bannerIndex.value + 1) % c.banners.length;

        controllerPage.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }
}
