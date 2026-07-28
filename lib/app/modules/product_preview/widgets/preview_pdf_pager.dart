import 'package:book_store_app/app/components/common_image_view.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/product_preview/controller/product_preview_controller.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Renders the first few pages of a PDF preview as watermarked page images —
/// no PDF file ever reaches the device, only per-page JPEG derivatives, so
/// there is nothing to "save as PDF".
class PreviewPdfPager extends StatelessWidget {
  final ProductPreviewController controller;
  final List<String> pages;

  const PreviewPdfPager({super.key, required this.controller, required this.pages});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: controller.pdfPageController,
            onPageChanged: (i) => controller.pdfPage.value = i,
            itemCount: pages.length,
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: CommonImageView(url: pages[i], fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: BaseSpacing.sm),
          child: Column(
            spacing: BaseSpacing.xs,
            children: [
              if (pages.length > 1)
                SmoothPageIndicator(
                  controller: controller.pdfPageController,
                  count: pages.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 6,
                    spacing: 6,
                    activeDotColor: AppColors.primaryColor,
                    dotColor: AppColors.gray600,
                  ),
                ),
              Obx(
                () => CustomText(
                  text: 'Page ${controller.pdfPage.value + 1} of ${pages.length} — preview only',
                  color: AppColors.gray600,
                  fontSize: AppFontSize.tiny,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
