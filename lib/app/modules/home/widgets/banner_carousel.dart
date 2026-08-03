import 'dart:async';
import 'package:book_store_app/app/components/custom_catagory_header.dart';
import 'package:book_store_app/app/data/repositories/promotions_repository.dart';
import 'package:book_store_app/app/modules/home/controllers/home_controller.dart';
import 'package:book_store_app/app/modules/home/models/banner_model.dart';
import 'package:book_store_app/app/services/promotion_attribution_service.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final c = Get.find<HomeController>();
  final PageController controllerPage = PageController();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Was called unconditionally from `build()` with a plain
    // `Timer.periodic` and no handle kept — every rebuild (e.g. whenever
    // any parent `Obx` fired) started a *new* timer stacked on top of
    // whatever was already running, so the carousel accelerated over time
    // and timers leaked for the lifetime of the app. Starting once here in
    // `initState` and cancelling in `dispose` fixes both.
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      if (controllerPage.hasClients && c.banners.isNotEmpty) {
        final nextPage = (c.bannerIndex.value + 1) % c.banners.length;
        controllerPage.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    controllerPage.dispose();
    super.dispose();
  }

  Future<void> _openBannerLink(BannerModel item) async {
    // Capture attribution + fire the click beacon regardless of whether the
    // banner actually has a link — a tap is a tap for tracking purposes.
    PromotionAttributionService.instance.capture('banner', item.id);
    PromotionsRepository().trackClick(entityType: 'banner', entityId: item.id);

    final urlOnTap = item.urlOnTap;
    if (urlOnTap == null || urlOnTap.trim().isEmpty) return;
    final uri = Uri.tryParse(urlOnTap.trim());
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) ToastUtil.showToast('Could not open this link.');
  }

  @override
  Widget build(BuildContext context) {
    if (c.banners.isEmpty) {
      return Shimmer.fromColors(
        baseColor: AppColors.gray600,
        highlightColor: AppColors.acceptedBg,
        child: SizedBox(height: Get.height / 5, width: double.infinity),
      );
    }

    // Fire the impression beacon for whichever page is currently visible.
    // `maybeTrackBannerImpression` dedupes per banner id per session, so
    // calling it here on every build (including the initially-visible
    // index 0, before any `onPageChanged` fires) is safe.
    final visibleIndex = c.bannerIndex.value.clamp(0, c.banners.length - 1);
    c.maybeTrackBannerImpression(c.banners[visibleIndex].id);

    return Column(
      children: [
        SizedBox(
          height: Get.height / 5,
          child: PageView.builder(
            controller: controllerPage,
            onPageChanged: (i) {
              c.bannerIndex.value = i;
              c.maybeTrackBannerImpression(c.banners[i].id);
            },
            itemCount: c.banners.length,
            itemBuilder: (_, i) {
              final item = c.banners[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: BaseSpacing.md),
                child: GestureDetector(
                  onTap: () => _openBannerLink(item),
                  child: CustomCatagoryHeader(productImage: item.image),
                ),
              );
            },
          ),
        ),

        SizedBox(height: BaseSpacing.xs + 2),

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
}
