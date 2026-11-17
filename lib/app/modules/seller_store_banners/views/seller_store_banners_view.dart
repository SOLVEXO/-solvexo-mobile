import 'package:book_store_app/app/components/custom_app_bar_two.dart';
import 'package:book_store_app/app/components/custom_confirm_dialog.dart';
import 'package:book_store_app/app/components/custom_refresh_wrapper.dart';
import 'package:book_store_app/app/components/custom_text.dart';
import 'package:book_store_app/app/data/models/store_banner/store_banner_model.dart';
import 'package:book_store_app/app/modules/seller_store_banners/controllers/seller_store_banners_controller.dart';
import 'package:book_store_app/app/modules/seller_store_banners/widgets/store_banner_card.dart';
import 'package:book_store_app/app/modules/seller_store_banners/widgets/store_banner_form_sheet.dart';
import 'package:book_store_app/app/modules/seller_store_banners/widgets/store_banner_timeline_sheet.dart';
import 'package:book_store_app/config/resources/app_colors.dart';
import 'package:book_store_app/core/theme/base_spacing.dart';
import 'package:book_store_app/utils/app_font_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerStoreBannersView extends StatelessWidget {
  SellerStoreBannersView({super.key});

  final SellerStoreBannersController c = Get.put(SellerStoreBannersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBarTwo(title: 'Store Banners', color: AppColors.black2),
      body: Stack(
        children: [
          Obx(() {
            if (c.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
            }

            if (c.banners.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(BaseSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.view_carousel_outlined, size: 48, color: AppColors.lightGrey),
                      SizedBox(height: BaseSpacing.sm),
                      CustomText(text: 'No storefront banners yet', color: AppColors.black2, fontSize: AppFontSize.extraSmall, fontWeight: FontWeight.w600),
                      SizedBox(height: BaseSpacing.xxs),
                      CustomText(
                        text: 'Create a hero banner to showcase promotions on your storefront.',
                        color: AppColors.gray600,
                        fontSize: AppFontSize.tiny,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return CustomRefreshWrapper(
              onRefresh: c.refreshData,
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(BaseSpacing.md, BaseSpacing.md, BaseSpacing.md, BaseSpacing.xxl * 2),
                itemCount: c.banners.length,
                separatorBuilder: (_, __) => SizedBox(height: BaseSpacing.sm),
                itemBuilder: (_, i) {
                  final banner = c.banners[i];
                  return StoreBannerCard(
                    banner: banner,
                    onEdit: () => StoreBannerFormSheet.show(context, c, existing: banner),
                    onDelete: () => _confirmDelete(context, banner),
                    onPause: () => c.pauseBanner(banner),
                    onResume: () => c.resumeBanner(banner),
                    onTimeline: () => StoreBannerTimelineSheet.show(context, c, banner.id),
                  );
                },
              ),
            );
          }),
          Positioned(
            right: BaseSpacing.md,
            bottom: BaseSpacing.md,
            child: FloatingActionButton.extended(
              heroTag: 'add_store_banner_fab',
              onPressed: () => StoreBannerFormSheet.show(context, c),
              backgroundColor: AppColors.primaryColor,
              icon: const Icon(Icons.add_rounded, color: AppColors.white),
              label: CustomText(text: 'New Banner', color: AppColors.white, fontSize: AppFontSize.tiny, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, StoreBannerModel banner) {
    CustomConfirmDialog.show(
      context,
      title: 'Delete this banner?',
      message: 'This will permanently remove the banner from your storefront carousel.',
      confirmLabel: 'Delete',
      confirmColor: AppColors.red,
      onConfirm: () => c.deleteBanner(banner),
    );
  }
}
