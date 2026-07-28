import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/modules/product_preview/controller/product_preview_controller.dart';
import 'package:book_store_app/app/modules/product_preview/widgets/preview_audio_player.dart';
import 'package:book_store_app/app/modules/product_preview/widgets/preview_image_view.dart';
import 'package:book_store_app/app/modules/product_preview/widgets/preview_pdf_pager.dart';
import 'package:book_store_app/app/modules/product_preview/widgets/preview_video_player.dart';
import 'package:book_store_app/app/modules/product_preview/widgets/product_preview_shimmer.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/core/widgets/buttons/base_buttons.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductPreviewView extends StatelessWidget {
  ProductPreviewView({super.key});

  final controller = Get.put(ProductPreviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const CustomText(text: 'Preview', color: AppColors.white),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ProductPreviewShimmer();
          }

          if (controller.hasError.value || controller.preview.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: AppColors.gray600,
                  ),
                  SizedBox(height: BaseSpacing.sm),
                  const CustomText(
                    text: 'Preview unavailable',
                    color: AppColors.gray600,
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: BaseSpacing.md),
                  GhostButton(
                    label: 'Try again',
                    onPressed: controller.fetchPreview,
                  ),
                ],
              ),
            );
          }

          final preview = controller.preview.value!;
          switch (preview.type) {
            case 'image':
              return PreviewImageView(url: preview.url ?? '');
            case 'pdf':
              return PreviewPdfPager(controller: controller, pages: preview.pages);
            case 'video':
              return PreviewVideoPlayer(controller: controller);
            case 'audio':
              return PreviewAudioPlayer(controller: controller, url: preview.url ?? '');
            default:
              return const Center(
                child: CustomText(
                  text: 'Preview unavailable',
                  color: AppColors.white,
                ),
              );
          }
        }),
      ),
    );
  }
}
